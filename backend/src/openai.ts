import { DiagnosisJSONSchema, SYSTEM_PROMPT } from "./schema";

export interface DiagnosisInput {
  /** Single-image field, preserved for back-compat with older clients. */
  imageBase64?: string;
  /** Preferred field: 1–3 base64-encoded images (any angle of the same plant). */
  images?: string[];
  mime: string;
  locale?: string;
  language?: string;
}

const LANGUAGE_NAMES: Record<string, string> = {
  en: "English",
  "zh-Hans": "Simplified Chinese",
  "zh-Hant": "Traditional Chinese",
  de: "German",
  fr: "French",
  ja: "Japanese",
  ko: "Korean",
  es: "Spanish",
};

function languageName(code: string | undefined): string {
  if (!code) return "English";
  return LANGUAGE_NAMES[code] ?? "English";
}

export interface DiagnosisOutput {
  plantName: string;
  scientificName: string;
  commonNames: string[];
  description: string;
  condition: string;
  severity: "healthy" | "mild" | "moderate" | "severe";
  confidence: number;
  causes: string[];
  fixes: string[];
  careTips: string[];
  light: string;
  water: string;
  soil: string;
  temperature: string;
  toxicity: string;
  disclaimer: string;
}

export const MAX_IMAGES = 3;

function collectImages(input: DiagnosisInput): string[] {
  if (input.images && input.images.length > 0) {
    return input.images.slice(0, MAX_IMAGES);
  }
  if (input.imageBase64) return [input.imageBase64];
  return [];
}

export async function callOpenAI(
  apiKey: string,
  input: DiagnosisInput,
): Promise<DiagnosisOutput> {
  const images = collectImages(input);
  if (images.length === 0) {
    throw new Error("no_images");
  }
  const lang = languageName(input.language);
  const multi = images.length > 1;
  const userText =
    `Diagnose this plant. ` +
    (multi
      ? `The user has supplied ${images.length} photos of the SAME plant from different angles / close-ups — ` +
        `weigh them together to improve identification accuracy. `
      : "") +
    `Respond in the structured JSON schema. ` +
    `Write every user-visible string field — plantName, scientificName, commonNames, description, condition, ` +
    `causes, fixes, careTips, light, water, soil, temperature, toxicity, and disclaimer — in ${lang}. ` +
    `The "severity" value MUST remain one of the English enum values: ` +
    `"healthy", "mild", "moderate", "severe". ` +
    `User locale: ${input.locale ?? "en-US"}.`;

  const imageContent = images.map((b64) => ({
    type: "image_url" as const,
    image_url: { url: `data:${input.mime};base64,${b64}` },
  }));

  const payload = {
    model: "gpt-4o",
    messages: [
      { role: "system", content: SYSTEM_PROMPT },
      {
        role: "user",
        content: [{ type: "text", text: userText }, ...imageContent],
      },
    ],
    response_format: {
      type: "json_schema",
      json_schema: DiagnosisJSONSchema,
    },
    max_tokens: 1200,
    temperature: 0.2,
  };

  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`OpenAI ${res.status}: ${text.slice(0, 500)}`);
  }

  const json = (await res.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const content = json.choices?.[0]?.message?.content;
  if (!content) throw new Error("OpenAI returned no content");

  const parsed = JSON.parse(content) as DiagnosisOutput;
  return parsed;
}
