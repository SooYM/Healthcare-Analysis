/**
 * Google Gemini API (API-key auth) — used as the primary LLM for the Explain panel.
 * Uses the REST endpoint directly so we don't need @google/generative-ai as a dep.
 * Includes retry with exponential backoff for rate-limit (429) and server (5xx) errors.
 */

const DEFAULT_BASE_URL = "https://generativelanguage.googleapis.com/v1beta";
const DEFAULT_MODEL = "gemini-2.5-flash";
const MAX_RETRIES = 2;
const TIMEOUT_MS = 30_000; // 30 seconds

const SYSTEM_INSTRUCTION = `You are a clinical research assistant integrated into a health biomarker dashboard. Your ONLY purpose is to help users understand health-related biomarker data, trends, correlations, and indicators shown on this dashboard.

STRICT RULES:
1. ONLY answer questions related to health biomarkers, medical lab results, clinical data interpretation, trends, correlations, and dashboard analytics.
2. If a user asks anything unrelated to health data or this dashboard (e.g. coding, general knowledge, jokes, politics, personal advice), politely decline and say: "I can only help with questions related to the health biomarker dashboard data. Please ask about biomarker trends, correlations, or indicators."
3. Never provide personal medical diagnoses or treatment recommendations. You may describe what indicators generally suggest in clinical contexts.
4. When explaining biomarker indicators, explain what normal ranges typically are, what high or low values may indicate clinically, and how they relate to other biomarkers in the data.
5. Use markdown formatting (bold, headers, lists) to make your response clear and readable.
6. Be precise, cautious, and evidence-based. If data is insufficient, say so.`;

async function fetchWithTimeout(url: string, init: RequestInit, timeoutMs: number): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function generateExplanationGemini(
  apiKey: string,
  prompt: string,
): Promise<string> {
  const baseUrl = process.env.GEMINI_BASE_URL || DEFAULT_BASE_URL;
  const primaryModel = process.env.GEMINI_MODEL || DEFAULT_MODEL;
  const fallbackModel = "gemini-2.0-flash";
  // Try primary model first, fall back to stable model on 503
  const modelsToTry = [primaryModel, ...(primaryModel !== fallbackModel ? [fallbackModel] : [])];

  const body = {
    system_instruction: {
      parts: [{ text: SYSTEM_INSTRUCTION }],
    },
    contents: [
      { role: "user", parts: [{ text: prompt }] },
    ],
    generationConfig: {
      maxOutputTokens: 2048,
      temperature: 0.35,
    },
  };

  let lastError: Error | null = null;

  for (const model of modelsToTry) {
    const endpoint = `${baseUrl}/models/${model}:generateContent`;
    const url = `${endpoint}?key=${apiKey}`;
    const init: RequestInit = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    };

    let modelFailed = false;

    for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
      try {
        const res = await fetchWithTimeout(url, init, TIMEOUT_MS);

        // On 503, try fallback model immediately instead of retrying same model
        if (res.status === 503 && modelsToTry.indexOf(model) < modelsToTry.length - 1) {
          console.warn(`Gemini ${model} returned 503, trying fallback model...`);
          modelFailed = true;
          break;
        }

        // Retry on rate-limit (429) or server errors (5xx)
        if ((res.status === 429 || res.status >= 500) && attempt < MAX_RETRIES) {
          const waitMs = 1000 * 2 ** attempt;
          console.warn(`Gemini ${model} returned ${res.status}, retrying in ${waitMs}ms (attempt ${attempt + 1}/${MAX_RETRIES})...`);
          await sleep(waitMs);
          continue;
        }

        if (!res.ok) {
          const errBody = await res.text().catch(() => "");
          throw new Error(`Gemini API ${res.status}: ${errBody.slice(0, 300)}`);
        }

        const json = await res.json();
        const text: string =
          json?.candidates?.[0]?.content?.parts
            ?.map((p: { text?: string }) => p.text ?? "")
            .join("") ?? "";

        if (!text.trim()) {
          const reason = json?.candidates?.[0]?.finishReason;
          if (reason === "SAFETY") {
            throw new Error("Response blocked by Gemini safety filters");
          }
          throw new Error("Empty response from Gemini API");
        }

        return text.trim();
      } catch (e) {
        lastError = e instanceof Error ? e : new Error(String(e));
        if (e instanceof Error && e.name === "AbortError") {
          lastError = new Error(`Gemini API timed out after ${TIMEOUT_MS / 1000}s`);
        }
        if (attempt < MAX_RETRIES) {
          const waitMs = 1000 * 2 ** attempt;
          console.warn(`Gemini ${model} error: ${lastError.message}. Retrying in ${waitMs}ms...`);
          await sleep(waitMs);
          continue;
        }
      }
    }

    if (modelFailed) continue;
  }

  throw lastError ?? new Error("Gemini API failed after retries");
}
