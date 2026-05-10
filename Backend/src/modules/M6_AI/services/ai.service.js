import * as writingEvaluation from "../evaluators/writing.evaluator.js";

export const processEvaluation = async (userId, attemptId, testType, moduleType, data) => {
    try {
        console.log(`[AI-Service] Starting ${moduleType} evaluation for Attempt: ${attemptId}`);
        switch (moduleType.toLowerCase()) {
            case 'writing':
                return await writingEvaluation.evaluateWriting(
                    userId,
                    attemptId,
                    testType,
                    data.question_text,
                    data.student_response
                );
            case 'speaking':
                throw new Error("Speaking evaluation is coming soon.");
            default:
                throw new Error(`Unsupported module type: ${moduleType}`);
        }
    } catch (error) {
        console.error(`[AI-Service-Error] Evaluation failed for ${attemptId}:`, error.message);
        throw error;
    }
};