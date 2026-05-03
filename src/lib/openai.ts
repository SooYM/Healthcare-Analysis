import OpenAI from "openai";

export async function generateExplanationOpenAI(
  apiKey: string,
  prompt: string,
): Promise<string> {
  const baseURL = process.env.OPENAI_BASE_URL || undefined;
  const model = process.env.OPENAI_MODEL || "gpt-4o";
  const client = new OpenAI({ apiKey, ...(baseURL ? { baseURL } : {}) });

  const response = await client.chat.completions.create({
    model,
    max_tokens: 2048,
    temperature: 0.35,
    messages: [
      {
        role: "system",
        content: `You are a clinical research assistant integrated into a health biomarker dashboard. Your ONLY purpose is to help users understand health-related biomarker data, trends, correlations, and indicators shown on this dashboard.

STRICT RULES:
1. ONLY answer questions related to health biomarkers, medical lab results, clinical data interpretation, trends, correlations, and dashboard analytics.
2. If a user asks anything unrelated to health data or this dashboard (e.g. coding, general knowledge, jokes, politics, personal advice), politely decline and say: "I can only help with questions related to the health biomarker dashboard data. Please ask about biomarker trends, correlations, or indicators."
3. Never provide personal medical diagnoses or treatment recommendations. You may describe what indicators generally suggest in clinical contexts.
4. When explaining biomarker indicators, explain what normal ranges typically are, what high or low values may indicate clinically, and how they relate to other biomarkers in the data.
5. Use markdown formatting (bold, headers, lists) to make your response clear and readable.
6. Be precise, cautious, and evidence-based. If data is insufficient, say so.`,
      },
      {
        role: "user",
        content: prompt,
      },
    ],
  });

  const text = response.choices?.[0]?.message?.content ?? "";

  if (!text.trim()) {
    throw new Error("Empty response from OpenAI");
  }

  return text.trim();
}
