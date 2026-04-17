const MAX_CLOCK_SKEW_SECONDS = 300;

export interface AuthResult {
  ok: boolean;
  reason?: string;
  deviceId?: string;
}

export async function verifyHMAC(
  req: Request,
  body: string,
  sharedSecret: string,
): Promise<AuthResult> {
  const ts = req.headers.get("X-PD-Timestamp");
  const deviceId = req.headers.get("X-PD-Device");
  const sig = req.headers.get("X-PD-Signature");

  if (!ts || !deviceId || !sig) {
    return { ok: false, reason: "missing_headers" };
  }

  const tsNum = Number.parseInt(ts, 10);
  if (!Number.isFinite(tsNum)) return { ok: false, reason: "bad_timestamp" };

  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - tsNum) > MAX_CLOCK_SKEW_SECONDS) {
    return { ok: false, reason: "timestamp_skew" };
  }

  const bodyHash = await sha256Hex(body);
  const message = `${ts}\n${deviceId}\n${bodyHash}`;
  const expected = await hmacSha256Hex(sharedSecret, message);

  if (!constantTimeEqual(expected, sig.toLowerCase())) {
    return { ok: false, reason: "bad_signature" };
  }

  return { ok: true, deviceId };
}

async function sha256Hex(input: string): Promise<string> {
  const data = new TextEncoder().encode(input);
  const buf = await crypto.subtle.digest("SHA-256", data);
  return bytesToHex(new Uint8Array(buf));
}

async function hmacSha256Hex(secret: string, message: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(message),
  );
  return bytesToHex(new Uint8Array(sig));
}

function bytesToHex(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += b.toString(16).padStart(2, "0");
  return s;
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}
