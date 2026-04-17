import { DiagnosisJSONSchema, SYSTEM_PROMPT } from "./schema";

export interface DiagnosisInput {
  imageBase64: string;
  mime: string;
  locale?: string;
}

export interface DiagnosisOutput {
  plantName: string;
  commonNames: string[];
  condition: string;
  severity: "healthy" | "mild" | "moderate" | "severe";
  confidence: number;
  causes: string[];
  fixes: string[];
  careTips: string[];
  disclaimer: string;
}

export async function callOpenAI(
  apiKey: string,
  input: DiagnosisInput,
): Promise<DiagnosisOutput> {
  const dataUrl = `data:${input.mime};base64,${input.imageBase64}`;
  const userText =
    `Diagnose this plant. Respond in the structured JSON schema. ` +
    `User locale: ${input.locale ?? "en-US"}.`;

  const payload = {
    model: "gpt-4o",
    messages: [
      { role: "system", content: SYSTEM_PROMPT },
      {
        role: "user",
        content: [
          { type: "text", text: userText },
          { type: "image_url", image_url: { url: dataUrl } },
        ],
      },
    ],
    response_format: {
      type: "json_schema",
      json_schema: DiagnosisJSONSchema,
    },
    max_tokens: 800,
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
