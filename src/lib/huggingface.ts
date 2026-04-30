const HF_CHAT_COMPLETIONS_URL =
  process.env.HUGGINGFACE_BASE_URL ||
  "https://router.huggingface.co/v1/chat/completions";

const HF_MODEL = process.env.HUGGINGFACE_MODEL || "google/medgemma-27b-text-it";

const SYSTEM_INSTRUCTION = `You are a clinical research assistant integrated into a health biomarker dashboard. Your ONLY purpose is to help users understand health-related biomarker data, trends, correlations, and indicators shown on this dashboard.

STRICT RULES:
1. ONLY answer questions related to health biomarkers, medical lab results, clinical data interpretation, trends, correlations, and dashboard analytics.
2. If a user asks anything unrelated to health data or this dashboard (e.g. coding, general knowledge, jokes, politics, personal advice), politely decline and say: "I can only help with questions related to the health biomarker dashboard data. Please ask about biomarker trends, correlations, or indicators."
3. Never provide personal medical diagnoses or treatment recommendations. You may describe what indicators generally suggest in clinical contexts.
4. When explaining biomarker indicators, explain what normal ranges typically are, what high or low values may indicate clinically, and how they relate to other biomarkers in the data.
5. Use markdown formatting (bold, headers, lists) to make your response clear and readable.
6. Be precise, cautious, and evidence-based. If data is insufficient, say so.`;

export async function generateExplanationHuggingFace(
  apiKey: string,
  prompt: string,
): Promise<string> {
  const res = await fetch(HF_CHAT_COMPLETIONS_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: HF_MODEL,
      temperature: 0.35,
      max_tokens: 2048,
      messages: [
        {
          role: "system",
          content: SYSTEM_INSTRUCTION,
        },
        {
          role: "user",
          content: prompt,
        },
      ],
    }),
  });

  if (!res.ok) {
    const errBody = await res.text().catch(() => "");
    throw new Error(`Hugging Face API ${res.status}: ${errBody.slice(0, 300)}`);
  }

  const json = await res.json();
  const text = json?.choices?.[0]?.message?.content ?? "";

  if (!text.trim()) {
    throw new Error("Empty response from Hugging Face");
  }

  return text.trim();
}
