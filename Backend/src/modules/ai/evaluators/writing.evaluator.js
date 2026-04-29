import { model } from '../../../config/gemini.js';
import { writingPrompt } from '../prompts/Gemini Prompts/writingEvaluation.prompt.js';
import * as aiModel from '../../../models/ai.model.js';
import { processWritingResponse } from '../processors (Input Cleaning)/writing.processor.js';

export const evaluateWriting = async (userId, attemptId, questionText, studentResponse) => {
    try {
        const { processedText } = processWritingResponse(studentResponse);
        const prompt = writingPrompt("IELTS Writing", questionText, processedText);
        const result = await model.generateContent(prompt);
        const response = await result.response;
        let text = response.text();
        const cleanJsonText = text.replace(/```json|```/gi, '').trim();
        const feedbackJson = JSON.parse(cleanJsonText);
        return await aiModel.saveFeedback({
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

    } catch (error) {
        console.error("Writing Evaluation Error:", error);
        throw new Error(`AI Evaluation Failed: ${error.message}`);
    }
};