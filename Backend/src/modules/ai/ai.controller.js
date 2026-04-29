import * as aiService from './ai.service.js';

export const evaluateSubmission = async (req, res) => {
    try {
        const { attempt_id, test_type, module_type, question_text, student_response } = req.body;
        const userId = req.user.id;
        if (!attempt_id || !student_response) {
            return res.status(400).json({ 
                success: false, 
                message: "Missing required fields: attempt_id and student_response are mandatory." 
            });
        }
        const feedback = await aiService.processEvaluation(
            userId,
            attempt_id,
            test_type || 'IELTS',
            module_type || 'writing',
            { question_text, student_response }
        );
        return res.status(200).json({
            success: true,
            message: "AI Evaluation completed successfully",
            data: feedback
        });
    } catch (error) {
        console.error("AI Controller Error:", error);
        return res.status(500).json({
            success: false,
            message: error.message || "An unexpected error occurred during AI evaluation"
        });
    }
};