import { bandFromReadingCorrect } from "../../../utils/bandScore.js";
import { tallyObjective } from "./objective.grade.js";

export { bandFromReadingCorrect };

/** Reading module score from already-graded responses. Does not call Gemini. */
export const evaluateReadingSection = (responses, examType = "IELTS") => {
  const rows = (responses || []).filter((r) => (r.section_type || "").toLowerCase() === "reading");
  const { correct, total } = tallyObjective(rows);
  const band = bandFromReadingCorrect(correct, total, examType);
  return {
    section: "reading",
    correct,
    total,
    band,
    feedback: total
      ? `Reading: ${correct}/${total} correct → band ${band}.`
      : "No graded reading questions.",
  };
};
