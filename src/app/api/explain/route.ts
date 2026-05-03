import { NextResponse } from "next/server";
import { z } from "zod";
import { getServerEnv } from "@/lib/env";
import { generateExplanationOpenAI } from "@/lib/openai";
import { generateExplanationHuggingFace } from "@/lib/huggingface";
import { annotateWithRanges, detectClinicalPatterns } from "@/lib/clinical-ranges";

/** JSON may contain null where client had NaN; Zod rejects NaN on number. */
const finiteOrNull = z.preprocess(
  (v) =>
    typeof v === "number" && !Number.isFinite(v)
      ? null
      : v,
  z.union([z.number(), z.null()]),
);

const summaryEntry = z.object({
  mean: finiteOrNull,
  std: finiteOrNull,
  min: finiteOrNull,
  max: finiteOrNull,
  n: z.number().int().nonnegative(),
});

const bodySchema = z.object({
  question: z.string().min(1).max(8000),
  context: z.object({
    filters: z
      .object({
        dateFrom: z.string(),
        dateTo: z.string(),
        biomarkers: z.array(z.string()).optional(),
      })
      .optional(),
    dataSource: z.enum(["bigquery", "demo"]),
    summary: z.record(z.string(), summaryEntry),
    correlation: z.record(
      z.string(),
      z.record(z.string(), z.union([z.number(), z.null()])),
    ),
    rowCount: z.number(),
    chartHint: z.string().optional(),
  }),
});

function fmt(n: number | null) {
  return n !== null && Number.isFinite(n) ? n.toFixed(3) : "n/a";
}

function localStubAnswer(question: string, ctx: z.infer<typeof bodySchema>["context"]) {
  const keys = Object.keys(ctx.summary).slice(0, 6);
  const lines = keys.map((k) => {
    const s = ctx.summary[k];
    if (!s || !s.n) return `${k}: no samples`;
    return `${k}: mean ${fmt(s.mean)} (n=${s.n}), range [${fmt(s.min)}, ${fmt(s.max)}]`;
  });
  return [
    "Offline mode (no LLM configured): here is a structured snapshot you can interpret.",
    `Data source: ${ctx.dataSource}. Rows in view: ${ctx.rowCount}.`,
    ctx.chartHint ? `Active view: ${ctx.chartHint}` : "",
    "Summary statistics:",
    ...lines,
    "",
    "Correlation matrix (Pearson on same patient+visit pairs) is included in context; values near 1 or -1 suggest linear association in this cohort.",
    "",
    `Your question: ${question}`,
  ]
    .filter(Boolean)
    .join("\n");
}

/**
 * Build enriched prompt with clinical reference ranges and pattern detection.
 */
function buildEnrichedPrompt(
  question: string,
  context: z.infer<typeof bodySchema>["context"],
): string {
  // Annotate biomarkers with clinical reference ranges + flags
  const annotatedStats = annotateWithRanges(
    context.summary as Record<string, { mean: number | null; std: number | null; min: number | null; max: number | null; n: number }>,
  );

  // Detect multi-biomarker clinical patterns
  const patterns = detectClinicalPatterns(
    context.summary as Record<string, { mean: number | null; n: number }>,
  );

  // Extract notable correlations (|r| > 0.3, skip diagonal)
  const corrPairs: string[] = [];
  const corrKeys = Object.keys(context.correlation);
  for (let i = 0; i < corrKeys.length; i++) {
    for (let j = i + 1; j < corrKeys.length; j++) {
      const a = corrKeys[i], b = corrKeys[j];
      const v = context.correlation[a]?.[b];
      if (typeof v === "number" && Math.abs(v) > 0.3) {
        corrPairs.push(`${a} × ${b}: r=${v.toFixed(3)}`);
      }
    }
  }
  const corrSummary = corrPairs.length
    ? corrPairs.slice(0, 20).join("\n")
    : "No notable correlations (|r| > 0.3) found.";

  const sections = [
    `Question: ${question}`,
    "",
    `Data source: ${context.dataSource}, ${context.rowCount} rows.`,
    context.filters
      ? `Filters: ${context.filters.dateFrom} to ${context.filters.dateTo}${context.filters.biomarkers?.length ? `, biomarkers: ${context.filters.biomarkers.join(", ")}` : ""}`
      : "",
    context.chartHint ?? "",
    "",
    "── Biomarker Statistics (with clinical reference ranges) ──",
    annotatedStats,
    "",
    "── Notable Correlations (Pearson) ──",
    corrSummary,
  ];

  if (patterns.length > 0) {
    sections.push(
      "",
      "── Detected Clinical Patterns ──",
      ...patterns,
    );
  }

  sections.push(
    "",
    "Instructions: Analyze the above data in clinical context. Reference the normal ranges, flag abnormalities, explain correlations, and identify patterns relevant to the user's question. Be precise and evidence-based.",
  );

  return sections.filter(Boolean).join("\n");
}

export async function POST(req: Request) {
  let json: unknown;
  try {
    json = await req.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  const parsed = bodySchema.safeParse(json);
  if (!parsed.success) {
    return NextResponse.json(
      { error: "Validation failed", details: parsed.error.flatten() },
      { status: 400 },
    );
  }

  const { question, context } = parsed.data;
  const env = getServerEnv();

  // Build enriched prompt with clinical context
  const prompt = buildEnrichedPrompt(question, context);

  // 1. Try Hugging Face MedGemma / Featherless AI (if HF token is set)
  const hfKey = process.env.HUGGINGFACE_API_KEY || process.env.HF_TOKEN;
  const errors: string[] = [];
  if (hfKey) {
    try {
      const answer = await generateExplanationHuggingFace(hfKey, prompt);
      return NextResponse.json({ answer, mode: "medgemma" as const });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error("Hugging Face / MedGemma explain error:", msg);
      errors.push(`MedGemma: ${msg}`);
    }
  }

  // 2. Try OpenAI (if OPENAI_API_KEY is set)
  const openaiKey = process.env.OPENAI_API_KEY;
  if (openaiKey) {
    try {
      const answer = await generateExplanationOpenAI(openaiKey, prompt);
      return NextResponse.json({ answer, mode: "openai" as const });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error("OpenAI explain error:", msg);
      errors.push(`OpenAI: ${msg}`);
    }
  }

  // 3. Local stub fallback — include error details so user knows why
  const answer = localStubAnswer(question, context);
  return NextResponse.json({
    answer,
    mode: "local_stub" as const,
    warning: errors.length
      ? `LLM errors: ${errors.join(" | ")}`
      : "Set HUGGINGFACE_API_KEY (or HF_TOKEN) for MedGemma, or OPENAI_API_KEY for fallback.",
  });
}
