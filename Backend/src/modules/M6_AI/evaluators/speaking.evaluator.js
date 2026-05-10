import { model } from "../../../config/gemini.js";
import { speakingPromptTemplate } from "../prompts/Gemini Prompts/speakingEvaluation.prompt.js";
import * as aiModel from "../../../models/ai.model.js";

export const evaluateSpeakingTask = async (userId, attemptId, transcriptionData) => {
    try {
        // 1. Prepare Speaking Specific Prompt
        const prompt = speakingPromptTemplate(
            transcriptionData.transcribedText, 
            transcriptionData.durationSeconds
        );
        // 2. Call Gemini
        const result = await model.generateContent(prompt);
        const feedbackJson = JSON.parse(result.response.text());

        // 3. Save to ai_feedback table
        // Note: Same model as writing, but we map speaking scores
        return await aiModel.saveFeedback({
            attempt_id: attemptId,
            user_id: userId,
            overall_band_score: feedbackJson.overall_band_score,
            // Speaking specific scores mapped to db columns
            task_response_score: feedbackJson.fluency_coherence_score, 
            lexical_resource_score: feedbackJson.lexical_resource_score,
            grammatical_range_score: feedbackJson.grammatical_range_score,
            detailed_analysis: feedbackJson.pronunciation_feedback,
            improvement_suggestions: feedbackJson.improvement_tips,
            model_used: 'gemini-1.5-flash'
        });
    } catch (error) {
        console.error("Speaking Evaluation Error:", error);
        throw new Error("AI Speaking evaluation failed");
    }
};