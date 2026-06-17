import * as aiService from "../services/ai.service.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";
import { getModuleFocusRecommendation } from "../services/performanceInsight.service.js";
import { generateJsonFromPrompt } from "../utils/gemini.helper.js";
import { buildFeedbackSuggestionPrompt } from "../prompts/performanceInsight.prompt.js";

export const evaluateSubmission = async (req, res) => {
  try {
    const { attempt_id, test_type, module_type, question_text, student_response } = req.body;
    const userId = req.user.id;
    if (!attempt_id || !student_response) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: attempt_id and student_response are mandatory.",
      });
    }
    const att = await progressModel.getAttemptById(attempt_id);
    if (!att || att.user_id !== userId) {
      return res.status(403).json({ success: false, message: "Invalid attempt" });
    }
    const feedback = await aiService.processEvaluation(
      userId,
      attempt_id,
      test_type || "IELTS",
      module_type || "writing",
      { question_text, student_response },
    );
    return res.status(200).json({
      success: true,
      message: "AI Evaluation completed successfully",
      data: feedback,
    });
  } catch (error) {
    console.error("AI Controller Error:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "An unexpected error occurred during AI evaluation",
    });
  }
};

export const evaluateSpeaking = async (req, res) => {
  try {
    const userId = req.user.id;
    const { attempt_id, transcribedText, durationSeconds } = req.body;
    if (!attempt_id || !transcribedText) {
      return res.status(400).json({ success: false, message: "attempt_id and transcribedText required" });
    }
    const att = await progressModel.getAttemptById(attempt_id);
    if (!att || att.user_id !== userId) {
      return res.status(403).json({ success: false, message: "Invalid attempt" });
    }
    const data = await aiService.processEvaluation(userId, attempt_id, "IELTS", "speaking", {
      transcribedText,
      durationSeconds,
    });
    return res.status(200).json({ success: true, data });
  } catch (error) {
    console.error("AI Speaking Controller Error:", error);
    return res.status(500).json({ success: false, message: error.message || "Speaking evaluation failed" });
  }
};

export const patchResponseAiFeedback = async (req, res) => {
  try {
    const { attempt_id, question_id, text } = req.body;
    if (!attempt_id || !question_id || text === undefined) {
      return res.status(400).json({ success: false, message: "attempt_id, question_id, text required" });
    }
    const att = await progressModel.getAttemptById(attempt_id);
    if (!att || att.user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: "Invalid attempt" });
    }
    const row = await progressModel.updateResponseAiFeedback(attempt_id, question_id, String(text));
    if (!row) return res.status(404).json({ success: false, message: "Response row not found" });
    return res.status(200).json({ success: true, data: row });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message || "Error" });
  }
};

export const getAiRecommendation = async (req, res) => {
  try {
    const examType = (req.query.exam_type || "IELTS").toUpperCase();
    const recommendation = await getModuleFocusRecommendation(req.user.id, examType);
    return res.status(200).json({ success: true, ...recommendation });
  } catch (error) {
    console.error("AI recommendation error:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const getAiFeedbackSuggestion = async (req, res) => {
  try {
    const examType = (req.query.exam_type || req.user?.preference || "IELTS").toUpperCase();
    const prompt = buildFeedbackSuggestionPrompt(examType);

    try {
      const json = await generateJsonFromPrompt(prompt);
      if (json.suggestion) {
        return res.status(200).json({ success: true, suggestion: String(json.suggestion).trim() });
      }
    } catch (apiErr) {
      console.warn("Gemini API error in feedback suggestion:", apiErr.message);
    }

    const fallbackSuggestions = [
      "The IELTS preparation content is very helpful. I would appreciate more full-length mock tests and real-time speaking evaluation.",
      "I really like the interactive Reading prep module, but it would be great to have more exercises for Matching Headings.",
      "The writing feedback is excellent, but please add an option to download the evaluation reports as PDF.",
      "PTE mock tests are locked for free users; maybe add one free PTE diagnostic test to let us try the format.",
    ];
    const suggestion = fallbackSuggestions[Math.floor(Math.random() * fallbackSuggestions.length)];
    return res.status(200).json({ success: true, suggestion });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};
