import { model } from "../../../config/gemini.js";
import { speakingPromptTemplate } from "../prompts/speakingEvaluation.prompt.js";
import * as aiModel from "../models/ai.model.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";

export const evaluateSpeakingTask = async (userId, attemptId, transcriptionData, isMultipartOptions = {}) => {
  try {
    const prompt = speakingPromptTemplate(
      transcriptionData.transcribedText || "",
      transcriptionData.durationSeconds ?? 0,
    );
    const result = await model.generateContent(prompt);
    const raw = (await result.response.text()).replace(/```json|```/gi, "").trim();
    const feedbackJson = JSON.parse(raw);

    await aiModel.saveFeedback({
      attempt_id: attemptId,
      user_id: userId,
      overall_band_score: feedbackJson.overall_band_score,
      task_response_score: feedbackJson.fluency_coherence_score,
      coherence_cohesion_score: feedbackJson.fluency_coherence_score,
      lexical_resource_score: feedbackJson.lexical_resource_score,
      grammatical_range_score: feedbackJson.grammatical_range_score,
      detailed_analysis: JSON.stringify({ pronunciation: feedbackJson.pronunciation_feedback }),
      improvement_suggestions: feedbackJson.improvement_tips,
      model_used: "gemini-1.5-flash",
    });

    if (!isMultipartOptions.skipScoreUpdate) {
      await progressModel.updateAttemptScores(attemptId, {
        overall_band_score: feedbackJson.overall_band_score,
        speaking_score: feedbackJson.overall_band_score,
        feedback: feedbackJson.improvement_tips || "Speaking evaluation complete.",
        status: "completed",
      });
      await progressModel.updateUserStats(userId);
    }

    return await aiModel.getFeedbackByAttempt(attemptId);
  } catch (error) {
    console.error("Speaking Evaluation Error:", error);
    throw new Error("AI Speaking evaluation failed");
  }
};