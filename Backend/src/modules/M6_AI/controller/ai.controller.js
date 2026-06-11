import * as aiService from "../services/ai.service.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";
import { model } from "../../../config/gemini.js";

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
    const examType = req.query.exam_type || "IELTS";
    const prompt = `Generate a JSON object with a single key "tip" containing a short, actionable study tip (under 20 words) for a student preparing for the ${examType} exam. Focus on either reading, writing, listening, speaking, or general time management. Return only the JSON structure.`;
    
    let tip = "";
    try {
      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text().trim();
      const json = JSON.parse(text);
      tip = json.tip;
    } catch (apiErr) {
      console.warn("Gemini API error in recommendation tip:", apiErr.message);
      const fallbackTips = [
        "Focus on Writing Task 2 - it carries the most weight in your score.",
        "Your Reading speed is key! Try the skimming strategy on long paragraphs.",
        "Listening practice: focus on signpost words like 'however' or 'finally'.",
        "Speaking Tip: Record yourself and listen for filler words like 'um' or 'uh'.",
        "Consistency is key! Keep up your daily streak for a higher band score."
      ];
      tip = fallbackTips[Math.floor(Math.random() * fallbackTips.length)];
    }
    
    return res.status(200).json({ success: true, tip });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const getAiFeedbackSuggestion = async (req, res) => {
  try {
    const prompt = `Generate a JSON object with a single key "suggestion" containing a single detailed feedback suggestion (around 20-30 words) that a student might write to the developers of an IELTS/PTE preparation app. It should be constructive, pointing out something good or suggesting a feature (like adding offline mode, speaking simulation, more mock tests, or dark mode). Return only the JSON structure.`;
    
    let suggestion = "";
    try {
      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text().trim();
      const json = JSON.parse(text);
      suggestion = json.suggestion;
    } catch (apiErr) {
      console.warn("Gemini API error in feedback suggestion:", apiErr.message);
      const fallbackSuggestions = [
        "The IELTS preparation content is very helpful. I would appreciate more full-length mock tests and real-time speaking evaluation.",
        "I really like the interactive Reading prep module, but it would be great to have more exercises for Matching Headings.",
        "The writing feedback is excellent, but please add an option to download the evaluation reports as PDF.",
        "PTE mock tests are locked for free users; maybe add one free PTE diagnostic test to let us try the format."
      ];
      suggestion = fallbackSuggestions[Math.floor(Math.random() * fallbackSuggestions.length)];
    }
    
    return res.status(200).json({ success: true, suggestion });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};
