import { GEMINI_MODEL_ID } from "../../../config/gemini.js";
import {
  generateJsonFromPrompt,
  generateJsonFromMultimodal,
} from "../utils/gemini.helper.js";
import {
  speakingPromptTemplate,
  speakingAudioPromptTemplate,
} from "../prompts/speakingEvaluation.prompt.js";
import {
  fetchAudioInlinePart,
  processAudioToText,
} from "../processors (Input Cleaning)/speaking.processor.js";
import * as aiModel from "../models/ai.model.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";

const persistSpeakingFeedback = async (userId, attemptId, feedbackJson, options = {}) => {
  await aiModel.saveFeedback({
    attempt_id: attemptId,
    user_id: userId,
    overall_band_score: feedbackJson.overall_band_score,
    task_response_score: feedbackJson.fluency_coherence_score,
    coherence_cohesion_score: feedbackJson.fluency_coherence_score,
    lexical_resource_score: feedbackJson.lexical_resource_score,
    grammatical_range_score: feedbackJson.grammatical_range_score,
    detailed_analysis: JSON.stringify({
      pronunciation: feedbackJson.pronunciation_feedback,
      source: feedbackJson._eval_source || "text",
    }),
    improvement_suggestions: feedbackJson.improvement_tips,
    model_used: GEMINI_MODEL_ID,
  });

  if (!options.skipScoreUpdate) {
    await progressModel.updateAttemptScores(attemptId, {
      overall_band_score: feedbackJson.overall_band_score,
      speaking_score: feedbackJson.overall_band_score,
      feedback: feedbackJson.improvement_tips || "Speaking evaluation complete.",
      status: "completed",
    });
    await progressModel.updateUserStats(userId);
  }

  return aiModel.getFeedbackByAttempt(attemptId);
};

const evaluateFromTranscript = async (transcriptionData) => {
  const prompt = speakingPromptTemplate(
    transcriptionData.transcribedText || "",
    transcriptionData.durationSeconds ?? 0,
    transcriptionData.questionText || transcriptionData.question_text || "",
    transcriptionData.cueCard || transcriptionData.cue_card || "",
  );
  const feedbackJson = await generateJsonFromPrompt(prompt);
  feedbackJson._eval_source = "stt_text";
  return feedbackJson;
};

const evaluateFromAudio = async (audioUrl, transcriptionData) => {
  const inlinePart = await fetchAudioInlinePart(audioUrl);
  const prompt = speakingAudioPromptTemplate(
    transcriptionData.questionText || transcriptionData.question_text || "",
    transcriptionData.cueCard || transcriptionData.cue_card || "",
    transcriptionData.transcribedText || "",
  );
  const feedbackJson = await generateJsonFromMultimodal([
    inlinePart,
    { text: prompt },
  ]);
  feedbackJson._eval_source = "audio_native";
  return feedbackJson;
};

/**
 * Prefer Gemini multimodal audio scoring when audio URL is available;
 * fall back to STT → text path on failure (STT path retained).
 */
export const evaluateSpeakingTask = async (
  userId,
  attemptId,
  transcriptionData,
  isMultipartOptions = {},
) => {
  try {
    const data = { ...(transcriptionData || {}) };
    const audioUrl =
      data.audioUrl || data.audio_response_url || data.audio_url || null;

    let feedbackJson = null;
    if (audioUrl && !isMultipartOptions.forceTextOnly) {
      try {
        feedbackJson = await evaluateFromAudio(audioUrl, data);
      } catch (audioErr) {
        console.warn(
          "[Speaking] Audio-native eval failed, falling back to STT/text:",
          audioErr?.message || audioErr,
        );
      }
    }

    if (!feedbackJson) {
      const existing = String(data.transcribedText || "").trim();
      if (!existing && audioUrl) {
        try {
          const stt = await processAudioToText(audioUrl);
          data.transcribedText = stt.transcribedText || "No speech detected";
          data.durationSeconds =
            stt.durationSeconds ?? data.durationSeconds ?? 0;
        } catch (sttErr) {
          console.warn(
            "[Speaking] STT fallback failed:",
            sttErr?.message || sttErr,
          );
          data.transcribedText = data.transcribedText || "No speech detected";
        }
      }
      if (!String(data.transcribedText || "").trim()) {
        data.transcribedText = "No speech detected";
      }
      feedbackJson = await evaluateFromTranscript(data);
    }

    return await persistSpeakingFeedback(
      userId,
      attemptId,
      feedbackJson,
      isMultipartOptions,
    );
  } catch (error) {
    console.error("Speaking Evaluation Error:", error);
    throw new Error("AI Speaking evaluation failed");
  }
};
