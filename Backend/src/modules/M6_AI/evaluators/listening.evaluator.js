import { bandFromListeningCorrect } from "../../../utils/bandScore.js";
import { tallyObjective } from "./objective.grade.js";

export { bandFromListeningCorrect };

/** Listening module score from already-graded responses. Does not call Gemini. */
export const evaluateListeningSection = (responses, examType = "IELTS") => {
  const rows = (responses || []).filter((r) => (r.section_type || "").toLowerCase() === "listening");
  const { correct, total } = tallyObjective(rows);
  const band = bandFromListeningCorrect(correct, total, examType);
  return {
    section: "listening",
    correct,
    total,
    band,
    feedback: total
      ? `Listening: ${correct}/${total} correct → band ${band}.`
      : "No graded listening questions.",
  };
};
