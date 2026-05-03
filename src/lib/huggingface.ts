/**
 * HuggingFace / Featherless AI inference client.
 * Supports any OpenAI-compatible chat completions endpoint:
 *   - HuggingFace Router: https://router.huggingface.co/v1/chat/completions
 *   - Featherless AI:     https://api.featherless.ai/v1/chat/completions
 *
 * Configure via env:
 *   HUGGINGFACE_BASE_URL  — full chat completions URL
 *   HUGGINGFACE_MODEL     — model id (default: google/medgemma-27b-text-it)
 *   HUGGINGFACE_API_KEY   — API key (or HF_TOKEN)
 */

const DEFAULT_URL = "https://api.featherless.ai/v1/chat/completions";
const DEFAULT_MODEL = "google/medgemma-27b-text-it";
const TIMEOUT_MS = 120_000; // 120s — 27B model on Featherless can be slow

const SYSTEM_INSTRUCTION = `You are a clinical research assistant integrated into a health biomarker dashboard. Your ONLY purpose is to help users understand health-related biomarker data, trends, correlations, and indicators shown on this dashboard.

STRICT RULES:
1. ONLY answer questions related to health biomarkers, medical lab results, clinical data interpretation, trends, correlations, and dashboard analytics.
2. If a user asks anything unrelated to health data or this dashboard (e.g. coding, general knowledge, jokes, politics, personal advice), politely decline and say: "I can only help with questions related to the health biomarker dashboard data. Please ask about biomarker trends, correlations, or indicators."
3. Never provide personal medical diagnoses or treatment recommendations. You may describe what indicators generally suggest in clinical contexts.
4. When explaining biomarker indicators, explain what normal ranges typically are, what high or low values may indicate clinically, and how they relate to other biomarkers in the data.
5. Use markdown formatting (bold, headers, lists) to make your response clear and readable.
6. Be precise, cautious, and evidence-based. If data is insufficient, say so.
7. When clinical reference ranges are provided in context, use them to assess whether values are normal, elevated, or low.
8. When clinical pattern alerts are provided, incorporate them into your analysis.
9. Respond DIRECTLY with your analysis. Do NOT include internal reasoning, chain-of-thought, or thinking steps. Jump straight to the answer.`;

export async function generateExplanationHuggingFace(
  apiKey: string,
  prompt: string,
): Promise<string> {
  const url = process.env.HUGGINGFACE_BASE_URL || DEFAULT_URL;
  const model = process.env.HUGGINGFACE_MODEL || DEFAULT_MODEL;

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        temperature: 0.35,
        max_tokens: 4096,
        messages: [
          { role: "system", content: SYSTEM_INSTRUCTION },
          { role: "user", content: prompt },
        ],
      }),
      signal: controller.signal,
    });

    if (!res.ok) {
      const errBody = await res.text().catch(() => "");
      // Provide actionable error messages
      if (res.status === 401 || res.status === 403) {
        throw new Error(`Authentication failed (${res.status}). Check your HUGGINGFACE_API_KEY.`);
      }
      if (res.status === 404) {
        throw new Error(`Model "${model}" not found. Check HUGGINGFACE_MODEL env var.`);
      }
      if (res.status === 429) {
        throw new Error(`Rate limited. Try again in a moment or upgrade your plan.`);
      }
      if (res.status === 503) {
        throw new Error(`Model is loading or unavailable. Try again in 30-60 seconds.`);
      }
      throw new Error(`API ${res.status}: ${errBody.slice(0, 300)}`);
    }

    const json = await res.json();
    let text: string = json?.choices?.[0]?.message?.content ?? "";

    // MedGemma 27B may include internal thinking tokens — strip them
    // Format: <unused94>thought\n...thinking...\n<unused95>\nactual response
    text = text.replace(/<unused\d+>thought[\s\S]*?<unused\d+>/g, "");
    // Also strip any remaining <unusedNN> tags
    text = text.replace(/<unused\d+>/g, "");
    // Clean up excessive leading newlines left after stripping
    text = text.replace(/^\n+/, "");

    if (!text.trim()) {
      throw new Error("Empty response from MedGemma");
    }

    return text.trim();
  } catch (e) {
    if (e instanceof Error && e.name === "AbortError") {
      throw new Error(`MedGemma request timed out after ${TIMEOUT_MS / 1000}s`);
    }
    throw e;
  } finally {
    clearTimeout(timer);
  }
}
