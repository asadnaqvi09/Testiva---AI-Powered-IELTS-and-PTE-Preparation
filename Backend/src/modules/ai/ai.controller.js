import * as aiService from './ai.service.js';

export const evaluateSubmission = async (req,res) => {
    try {
        const { attempt_id, test_type, module_type, question_text, student_response } = req.body;
        const userID = req.user.id;
        const feedback = await aiService.processEvaluation(
            userID,
            attempt_id,
            test_type,
            module_type,
            { question_text, student_response }
        );
        res.status(200).json({
            success: true,
            message: "AI Evaluation completed successfully",
            data: feedback
        });
    } catch (error) {
        console.error("AI Controller Error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "AI Evaluation failed"
        });
    }
}