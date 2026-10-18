import { roundIeltsBand, roundPteBand } from "../../../utils/bandScore.js";

const clampBand = (value, examType = "IELTS") => {
  const n = Number(value);
  if (!Number.isFinite(n)) return 0;
  const clipped = Math.min(9, Math.max(0, n));
  return (examType || "").toUpperCase() === "PTE" ? roundPteBand(clipped) : roundIeltsBand(clipped);
};

const pickScore = (modelJson, breakdownKey, flatKey) => {
  const fromBreakdown = modelJson?.breakdown?.[breakdownKey]?.score;
  if (fromBreakdown != null && fromBreakdown !== "") return fromBreakdown;
  return modelJson?.[flatKey];
};

const asText = (value) => {
  if (value == null) return "";
  if (Array.isArray(value)) return value.filter(Boolean).join("\n");
  if (typeof value === "string") return value;
  return JSON.stringify(value);
};

/**
 * Apply IELTS/PTE writing scoring rules to an already-returned Gemini JSON.
 * Does not call the model.
 */
export const scoreWritingFromModel = (modelJson = {}, meta = {}) => {
  const examType = meta.examType || "IELTS";
  const wordCount = Number(meta.wordCount) || 0;
  const minWords = Number(meta.minWords) || 0;

  const task = clampBand(pickScore(modelJson, "task_response", "task_response_score"), examType);
  const cohesion = clampBand(pickScore(modelJson, "coherence_cohesion", "coherence_cohesion_score"), examType);
  const lexical = clampBand(pickScore(modelJson, "lexical_resource", "lexical_resource_score"), examType);
  const grammar = clampBand(
    pickScore(modelJson, "grammatical_range_accuracy", "grammatical_range_score"),
    examType,
  );

  let overall = (task + cohesion + lexical + grammar) / 4;
  if (modelJson.overall_band_score != null && Number.isFinite(Number(modelJson.overall_band_score))) {
    overall = (overall + clampBand(modelJson.overall_band_score, examType)) / 2;
  }

  if (wordCount > 0 && wordCount < 20) {
    overall = Math.min(overall, 3);
  } else if (minWords > 0 && wordCount > 0 && wordCount < minWords) {
    overall = Math.min(overall, 5);
  }

  overall = clampBand(overall, examType);

  return {
    overall_band_score: overall,
    task_response_score: task,
    coherence_cohesion_score: cohesion,
    lexical_resource_score: lexical,
    grammatical_range_score: grammar,
    detailed_analysis: modelJson.detailed_analysis ?? {},
    improvement_suggestions: asText(modelJson.improvement_suggestions),
    overall_comment: asText(modelJson.overall_comment),
    word_count: wordCount || Number(modelJson.word_count) || 0,
  };
};
