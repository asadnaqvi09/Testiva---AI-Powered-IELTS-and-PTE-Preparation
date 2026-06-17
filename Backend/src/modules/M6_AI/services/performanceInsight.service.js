import { analyzeWeakness } from "../../../utils/weaknessAnalyzer.js";
import { generateJsonFromPrompt } from "../utils/gemini.helper.js";
import { buildModuleFocusPrompt } from "../prompts/performanceInsight.prompt.js";

const MODULES = ["Reading", "Writing", "Listening", "Speaking"];

const pickWeakestModule = (sectionScores, examType) => {
  const entries = MODULES.map((name) => ({
    name,
    score: Number(sectionScores[name.toLowerCase()]) || 0,
  }));
  const hasAnyScore = entries.some((e) => e.score > 0);
  if (!hasAnyScore) {
    return (examType || "IELTS").toUpperCase() === "PTE" ? "Speaking" : "Writing";
  }
  entries.sort((a, b) => a.score - b.score);
  return entries[0].name;
};

const fallbackRecommendation = (examType, performance) => {
  const focusModule = pickWeakestModule(performance.sectionScores, examType);
  const score = Number(performance.sectionScores[focusModule.toLowerCase()]) || 0;
  const tips = {
    Reading: "Practice skimming and scanning — your Reading module needs the most attention right now.",
    Writing: "Focus on Writing Task 2 structure and coherence to lift your lowest band score.",
    Listening: "Drill Listening for signpost words and note-taking to strengthen your weakest area.",
    Speaking: "Record daily speaking answers and reduce filler words to improve your Speaking band.",
  };
  return {
    tip: tips[focusModule],
    focus_module: focusModule,
    reason:
      score > 0
        ? `Your ${focusModule} average (${score}) is your lowest section score.`
        : `Start with ${focusModule} — it typically offers the fastest band improvement for ${examType} learners.`,
    source: "fallback",
  };
};

export const getModuleFocusRecommendation = async (userId, examType = "IELTS") => {
  const performance = await analyzeWeakness(userId);

  try {
    const prompt = buildModuleFocusPrompt(examType, performance);
    const json = await generateJsonFromPrompt(prompt);
    const focusModule = MODULES.find(
      (m) => m.toLowerCase() === String(json.focus_module || "").toLowerCase(),
    );
    if (!json.tip || !focusModule) {
      throw new Error("Incomplete AI response");
    }
    return {
      tip: String(json.tip).trim(),
      focus_module: focusModule,
      reason: String(json.reason || "").trim() || `Focus on ${focusModule} to improve your band.`,
      source: "ai",
    };
  } catch (err) {
    console.warn("Gemini module-focus recommendation failed:", err.message);
    return fallbackRecommendation(examType, performance);
  }
};
