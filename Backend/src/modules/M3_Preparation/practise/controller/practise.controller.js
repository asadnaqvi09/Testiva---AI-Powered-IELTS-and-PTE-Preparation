import pool from "../../../../config/db.js";
import * as practiceModel from "../practise.model.js";

export const startPractice = async (req, res) => {
    try {
        const { section_name, question_type, difficulty_level } = req.body;
        const session = await practiceModel.createPracticeSession({
            user_id: req.user.id, section_name, question_type, difficulty_level
        });
        const questions = await practiceModel.getPracticeQuestion(
            req.user.id, section_name, question_type, difficulty_level, 1
        );
        res.status(201).json({ success: true, data: { session, questions } });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const submitPracticeAnswer = async (req, res) => {
    try {
        const { session_id, question_id, user_answer, time_taken_seconds } = req.body;
        const qRes = await pool.query(
            `SELECT correct_answer, marks FROM questions WHERE id = $1`,
            [question_id]
        );
        const question = qRes.rows[0];
        const isCorrect = user_answer?.trim().toLowerCase() === question.correct_answer?.trim().toLowerCase();
        const marks = isCorrect ? question.marks : 0;
        const response = await practiceModel.savePracticeResponse({
            session_id, question_id, user_answer, is_correct: isCorrect,
            marks_obtained: marks, time_taken_seconds
        });
        res.status(200).json({ success: true, data: { ...response, correct_answer: question.correct_answer } });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const completePractice = async (req, res) => {
    try {
        const { session_id } = req.params;
        const result = await practiceModel.completePracticeSession(session_id);
        res.status(200).json({ success: true, data: result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const getPracticeHistory = async (req, res) => {
    try {
        const stats = await practiceModel.getPracticeStats(req.user.id);
        const sessions = await practiceModel.getRecentPracticeSessions(req.user.id);
        res.status(200).json({ success: true, data: { stats, sessions } });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};