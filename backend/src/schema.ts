export const DiagnosisJSONSchema = {
  name: "PlantDiagnosis",
  schema: {
    type: "object",
    additionalProperties: false,
    required: [
      "plantName",
      "commonNames",
      "condition",
      "severity",
      "confidence",
      "causes",
      "fixes",
      "careTips",
      "disclaimer",
    ],
    properties: {
      plantName: {
        type: "string",
        description: "Most likely botanical or common name of the plant.",
      },
      commonNames: {
        type: "array",
        items: { type: "string" },
        description: "Alternative common names.",
      },
      condition: {
        type: "string",
        description: "Short label of the primary issue, or 'Healthy'.",
      },
      severity: {
        type: "string",
        enum: ["healthy", "mild", "moderate", "severe"],
      },
      confidence: {
        type: "number",
        description: "0.0-1.0 model confidence in the diagnosis.",
      },
      causes: {
        type: "array",
        items: { type: "string" },
        description: "Likely root causes of the condition.",
      },
      fixes: {
        type: "array",
        items: { type: "string" },
        description: "Concrete actions the gardener can take.",
      },
      careTips: {
        type: "array",
        items: { type: "string" },
        description: "General ongoing care advice for this plant.",
      },
      disclaimer: { type: "string" },
    },
  },
  strict: true,
} as const;

export const SYSTEM_PROMPT = `You are Leafwise, an AI plant-health assistant for backyard gardeners. \
Given a photo of a plant, identify the plant and diagnose any visible problem \
(disease, pest, nutrient deficiency, environmental stress, or healthy). \
Respond ONLY in the provided JSON schema. Be specific and actionable. \
If the image is not a plant or is too blurry to analyze, set severity to "mild", \
condition to "Unable to analyze", confidence <= 0.2, and describe what would \
help in causes/fixes. Always include a brief disclaimer that this is AI guidance.`;
