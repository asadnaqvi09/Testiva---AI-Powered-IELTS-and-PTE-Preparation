import * as writingEvaluation from "./evaluators/writing.evaluator.js";

export const processEvaluation = async (userId, attemptId, testType, moduleType, data) => {
    // ModuleType 'writing' hai ya 'speaking', uske mutabiq function call karein
    if (moduleType === 'writing') {
        return await writingEvaluation.evaluateWriting(
            userId, 
            attemptId, 
            data.question_text, 
            data.student_response
        );
    }
    if (moduleType === 'speaking') {
        // Future: Speaking evaluator yahan call hoga
        throw new Error("Speaking evaluation is currently in development");
    }

    throw new Error("Invalid module type for AI evaluation");
};