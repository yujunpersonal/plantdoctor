import { verifyHMAC } from "./auth";
import { enforceRateLimits, type RateLimiter } from "./ratelimit";
import { callOpenAI, type DiagnosisInput } from "./openai";

export interface Env {
  OPENAI_API_KEY: string;
  SHARED_SECRET: string;
  RL_GLOBAL: RateLimiter;
  RL_DEVICE: RateLimiter;
  ALLOWED_ORIGIN: string;
}

const MAX_BODY_BYTES = 4 * 1024 * 1024; // 4MB ceiling after 1024px resize

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    if (req.method === "GET" && url.pathname === "/health") {
      return text("ok");
    }

    if (req.method !== "POST" || url.pathname !== "/diagnose") {
      return json({ error: "not_found" }, 404);
    }

    const rawBody = await req.text();
    if (rawBody.length > MAX_BODY_BYTES) {
      return json({ error: "payload_too_large" }, 413);
    }

    const auth = await verifyHMAC(req, rawBody, env.SHARED_SECRET);
    if (!auth.ok || !auth.deviceId) {
      return json({ error: "auth", reason: auth.reason }, 401);
    }

    const rl = await enforceRateLimits(env.RL_GLOBAL, env.RL_DEVICE, auth.deviceId);
    if (!rl.ok) {
      return json(
        { error: "rate_limited", scope: rl.scope, retryAfter: 60 },
        429,
        { "Retry-After": "60" },
      );
    }

    let input: DiagnosisInput;
    try {
      input = JSON.parse(rawBody) as DiagnosisInput;
    } catch {
      return json({ error: "bad_json" }, 400);
    }

    if (!input.imageBase64 || !input.mime) {
      return json({ error: "missing_fields" }, 400);
    }

    try {
      const diagnosis = await callOpenAI(env.OPENAI_API_KEY, input);
      return json(diagnosis, 200);
    } catch (err) {
      console.error("openai_error", err);
      return json({ error: "server" }, 500);
    }
  },
} satisfies ExportedHandler<Env>;

function json(
  body: unknown,
  status: number,
  extraHeaders: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...extraHeaders,
    },
  });
}

function text(body: string, status = 200): Response {
  return new Response(body, {
    status,
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}
