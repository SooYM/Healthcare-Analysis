import { VertexAI } from "@google-cloud/vertexai";
import type { AppEnv } from "@/lib/env";

export async function generateExplanation(
  env: AppEnv,
  prompt: string,
): Promise<string> {
  const project = env.GCP_PROJECT_ID;
  if (!project) {
    throw new Error("GCP_PROJECT_ID is required for Vertex AI");
  }

  const vertex = new VertexAI({
    project,
    location: env.VERTEX_LOCATION,
  });

  const model = vertex.getGenerativeModel({
    model: env.VERTEX_MODEL,
    generationConfig: {
      maxOutputTokens: 2048,
      temperature: 0.35,
    },
    systemInstruction: {
      role: "system",
      parts: [
        {
          text: `You are a clinical research assistant helping interpret biomarker dashboards. 
Be precise, cautious, and non-diagnostic: describe relationships, trends, and what charts show in statistical terms.
If data is insufficient, say so. Never give personal medical advice or diagnoses.`,
        },
      ],
    },
  });

  const result = await model.generateContent({
    contents: [{ role: "user", parts: [{ text: prompt }] }],
  });
  const text =
    result.response.candidates?.[0]?.content?.parts
      ?.map((p) => ("text" in p ? p.text : ""))
      .join("") ?? "";

  if (!text.trim()) {
    throw new Error("Empty response from Vertex AI");
  }

  return text.trim();
}
