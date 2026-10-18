import { GEMINI_MODEL_ID } from "../../../config/gemini.js";
import { generateJsonFromPrompt } from "../utils/gemini.helper.js";
import { writingPrompt } from "../prompts/writingEvaluation.prompt.js";
import * as aiModel from "../models/ai.model.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";
import { processWritingResponse } from "../processors (Input Cleaning)/writing.processor.js";
import { scoreWritingFromModel } from "./writing.logic.js";

export { scoreWritingFromModel };

export const evaluateWriting = async (userId, attemptId, testType, questionText, studentResponse, isMultipartOptions = {}) => {
  try {
    const { processedText, wordCount } = processWritingResponse(studentResponse);
    const prompt = writingPrompt(`${testType || "IELTS"} Writing`, questionText, processedText);
    const modelJson = await generateJsonFromPrompt(prompt);
    const scored = scoreWritingFromModel(modelJson, {
      examType: testType,
      wordCount,
      minWords: isMultipartOptions.minWords || 0,
    });
    const detailed = scored.detailed_analysis ?? {};

    await aiModel.saveFeedback({
      attempt_id: attemptId,
      user_id: userId,
      overall_band_score: scored.overall_band_score,
      task_response_score: scored.task_response_score,
      coherence_cohesion_score: scored.coherence_cohesion_score,
      lexical_resource_score: scored.lexical_resource_score,
      grammatical_range_score: scored.grammatical_range_score,
      detailed_analysis: typeof detailed === "string" ? detailed : JSON.stringify(detailed),
      improvement_suggestions: scored.improvement_suggestions,
      model_used: GEMINI_MODEL_ID,
    });

    if (!isMultipartOptions.skipScoreUpdate) {
      const fbText = [scored.improvement_suggestions, scored.overall_comment].filter(Boolean).join("\n");
      await progressModel.updateAttemptScores(attemptId, {
        overall_band_score: scored.overall_band_score,
        writing_score: scored.overall_band_score,
        feedback: fbText || "Writing evaluation complete.",
        status: "completed",
      });
      await progressModel.updateUserStats(userId);
    }

    return await aiModel.getFeedbackByAttempt(attemptId);
  } catch (error) {
    console.error("Writing Evaluation Error:", error);
    if (!isMultipartOptions.skipScoreUpdate) {
      await progressModel.updateAttemptScores(attemptId, {
        status: "failed",
        feedback: "AI Evaluation failed. Please contact support.",
      }).catch((err) => console.error("Finalize Error during AI failure:", err));
    }
    throw new Error(`AI Evaluation Failed: ${error.message}`);
  }
};
