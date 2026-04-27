import {model} from '../../../config/gemini.js';
import { writingPrompt } from '../prompts/Gemini Prompts/writingEvaluation.prompt.js';
import * as aiModel from '../../../models/ai.model.js';

export const evaluateWriting = async (userID,attempt_id,questionText,studentResponse) => {
    try {
        // 1. Prepare Prompt
        const prompt = writingPrompt("IELTS Writing", questionText, studentResponse);

        // 2. Call Gemini API
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const feedbackJson = JSON.parse(response.text());

        // 3. Save to Database via AI Model
        const savedFeedback = await aiModel.saveFeedback({
            attempt_id: attemptId,
            user_id: userId,
            overall_band_score: feedbackJson.overall_band_score,
            task_response_score: feedbackJson.task_response_score,
            coherence_cohesion_score: feedbackJson.coherence_cohesion_score,
            lexical_resource_score: feedbackJson.lexical_resource_score,
            grammatical_range_score: feedbackJson.grammatical_range_score,
            detailed_analysis: feedbackJson.detailed_analysis,
            improvement_suggestions: feedbackJson.improvement_suggestions,
            model_used: 'gemini-1.5-flash'
        });

        return savedFeedback;
    } catch (error) {
        console.error("Writing Evaluation Error:", error);
        throw new Error("Failed to evaluate writing task via Gemini");
    }
}