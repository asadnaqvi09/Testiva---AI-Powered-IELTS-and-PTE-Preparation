import * as writingEvaluation from "../evaluators/writing.evaluator.js";
import * as speakingEvaluation from "../evaluators/speaking.evaluator.js";

export const processEvaluation = async (userId, attemptId, testType, moduleType, data) => {
  const mod = (moduleType || "writing").toLowerCase();
  if (mod === "writing") {
    return await writingEvaluation.evaluateWriting(
      userId,
      attemptId,
      testType,
      data.question_text,
      data.student_response,
    );
  }
  if (mod === "speaking") {
    return await speakingEvaluation.evaluateSpeakingTask(userId, attemptId, data);
  }
  throw new Error(`Unsupported module type: ${moduleType}`);
};
