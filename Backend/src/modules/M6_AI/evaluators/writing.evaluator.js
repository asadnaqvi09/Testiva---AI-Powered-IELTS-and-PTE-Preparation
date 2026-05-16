import { model } from "../../../config/gemini.js";
import { writingPrompt } from "../prompts/writingEvaluation.prompt.js";
import * as aiModel from "../models/ai.model.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";
import { processWritingResponse } from "../processors (Input Cleaning)/writing.processor.js";

export const evaluateWriting = async (userId, attemptId, testType, questionText, studentResponse) => {
  try {
    const { processedText } = processWritingResponse(studentResponse);
    const prompt = writingPrompt(`${testType || "IELTS"} Writing`, questionText, processedText);
    const result = await model.generateContent(prompt);
    const response = await result.response;
    let text = response.text();
    const cleanJsonText = text.replace(/```json|```/gi, "").trim();
    const feedbackJson = JSON.parse(cleanJsonText);
    const detailed = feedbackJson.detailed_analysis ?? {};
    await aiModel.saveFeedback({
      attempt_id: attemptId,
      user_id: userId,
      overall_band_score: feedbackJson.overall_band_score,
      task_response_score: feedbackJson.breakdown?.task_response?.score ?? feedbackJson.task_response_score,
      coherence_cohesion_score: feedbackJson.breakdown?.coherence_cohesion?.score ?? feedbackJson.coherence_cohesion_score,
      lexical_resource_score: feedbackJson.breakdown?.lexical_resource?.score ?? feedbackJson.lexical_resource_score,
      grammatical_range_score:
        feedbackJson.breakdown?.grammatical_range_accuracy?.score ?? feedbackJson.grammatical_range_score,
      detailed_analysis: typeof detailed === "string" ? detailed : JSON.stringify(detailed),
      improvement_suggestions: feedbackJson.improvement_suggestions,
      model_used: "gemini-1.5-flash",
    });
    const fbText = [feedbackJson.improvement_suggestions, feedbackJson.overall_comment].filter(Boolean).join("\n");
    await progressModel.updateAttemptScores(attemptId, {
      overall_band_score: feedbackJson.overall_band_score,
      writing_score: feedbackJson.overall_band_score,
      feedback: fbText || "Writing evaluation complete.",
      status: "completed",
    });
    await progressModel.updateUserStats(userId);
    return await aiModel.getFeedbackByAttempt(attemptId);
  } catch (error) {
    console.error("Writing Evaluation Error:", error);
    await progressModel.updateAttemptScores(attemptId, {
      status: "failed",
      feedback: "AI Evaluation failed. Please contact support.",
    }).catch((err) => console.error("Finalize Error during AI failure:", err));
    throw new Error(`AI Evaluation Failed: ${error.message}`);
  }
};
