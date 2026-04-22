export const DiagnosisJSONSchema = {
  name: "PlantDiagnosis",
  schema: {
    type: "object",
    additionalProperties: false,
    required: [
      "plantName",
      "scientificName",
      "commonNames",
      "description",
      "condition",
      "severity",
      "confidence",
      "causes",
      "fixes",
      "careTips",
      "light",
      "water",
      "soil",
      "temperature",
      "toxicity",
      "disclaimer",
    ],
    properties: {
      plantName: {
        type: "string",
        description:
          "Everyday common name a non-expert would recognize (e.g. 'Snake plant', not 'Dracaena trifasciata'). Never leave empty — if uncertain, give the best-guess friendly name.",
      },
      scientificName: {
        type: "string",
        description:
          "Botanical / Latin name (e.g. 'Dracaena trifasciata'). Empty string if genuinely unknown.",
      },
      commonNames: {
        type: "array",
        items: { type: "string" },
        description:
          "Additional alternative common names besides plantName. May be empty.",
      },
      description: {
        type: "string",
        description:
          "2-3 sentence friendly description of what this plant is — origin, typical use (houseplant / garden / edible), distinguishing look. Written for a non-expert who may not know the plant.",
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
      light: {
        type: "string",
        description:
          "One-line light requirement (e.g. 'Bright, indirect light; tolerates low light').",
      },
      water: {
        type: "string",
        description:
          "One-line watering guidance including frequency and how to check (e.g. 'Water when top 2 inches of soil are dry, roughly weekly').",
      },
      soil: {
        type: "string",
        description:
          "One-line soil / potting / fertilizer guidance (e.g. 'Well-draining potting mix; feed monthly in growing season').",
      },
      temperature: {
        type: "string",
        description:
          "One-line temperature and humidity range (e.g. '18–27°C (65–80°F); average household humidity').",
      },
      toxicity: {
        type: "string",
        description:
          "One-line toxicity note for pets and people (e.g. 'Mildly toxic to cats and dogs if ingested' or 'Non-toxic').",
      },
      disclaimer: { type: "string" },
    },
  },
  strict: true,
} as const;

export const SYSTEM_PROMPT = `You are Leafwise, an AI plant-health assistant for backyard gardeners and everyday houseplant owners. \
Given a photo of a plant, identify the plant and diagnose any visible problem \
(disease, pest, nutrient deficiency, environmental stress, or healthy). \
Respond ONLY in the provided JSON schema.

Naming rules:
- "plantName" MUST be the everyday common name a non-expert would recognize (e.g. "Snake plant", "Monstera", "Tomato"), never the Latin binomial.
- "scientificName" is the botanical/Latin name (e.g. "Dracaena trifasciata"). Set it to an empty string only if genuinely unknown.
- "commonNames" lists additional alternative common names, and may be empty.

Content rules:
- "description" is 2-3 friendly sentences for someone who may not know the plant: what it is, where it's from or typically grown, and a distinguishing feature.
- "light", "water", "soil", "temperature", "toxicity" are each a single practical sentence.
- "causes", "fixes", "careTips" are concise bullet-ready strings.
- Always include a brief "disclaimer" that this is AI guidance.

If the image is not a plant or is too blurry to analyze, set severity to "mild", \
condition to "Unable to analyze", confidence <= 0.2, plantName to "Unknown plant", \
leave scientificName empty, and describe what would help in causes/fixes.`;
