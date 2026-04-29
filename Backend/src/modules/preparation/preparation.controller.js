import pool from "../../config/db.js";
import * as prepModel from "../../models/preparation.model.js";
import * as practiceModel from "../../models/practise.model.js";
import * as studyPlanModel from "../../models/studyPlan.model.js";
import { generateRecommendations } from "../../utils/recommendationEngine.js";
import { generateStudyPlan } from "../../utils/studyPlanGenerator.js";
import { analyzeWeakness } from "../../utils/weaknessAnalyzer.js";
import { createLessonSchema, updateLessonSchema, updatePartSchema, lessonFilterSchema } from "./preparation.validator.js";

export const createPrepLesson = async (req, res) => {
    const client = await pool.connect();
    try {
        const { error, value } = createLessonSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        const { title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, parts } = value;
        const created_by = req.user.id;
        await client.query("BEGIN");
        const header = await prepModel.createPreparationHeader({
            title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, created_by
        }, client);
        if (parts && parts.length > 0) {
            for (const part of parts) {
                await prepModel.createPreparationPart({
                    lesson_id: header.id, part_title: part.part_title,
                    part_content: part.part_content, order_number: part.order_number
                }, client);
            }
        }
        await client.query("COMMIT");
        res.status(201).json({ success: true, message: "Lesson created", data: { id: header.id } });
    } catch (error) {
        await client.query("ROLLBACK");
        res.status(500).json({ success: false, message: error.message });
    } finally {
        client.release();
    }
};

export const getPrepLessons = async (req, res) => {
    try {
        const { error, value } = lessonFilterSchema.validate(req.query);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        const subscription = req.user.subscription;
        const lessons = await prepModel.getLessonsBySubscription(subscription, value.test_type, value.section);
        res.status(200).json({ success: true, count: lessons.length, data: lessons });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const getPrepDetails = async (req, res) => {
    try {
        const { id } = req.params;
        const fullPrep = await prepModel.getFullPrepByID(id);
        if (!fullPrep) return res.status(404).json({ success: false, message: "Lesson not found" });
        const allowed = ['free'];
        if (req.user.subscription === 'basic' || req.user.subscription === 'premium') allowed.push('basic');
        if (req.user.subscription === 'premium') allowed.push('premium');
        if (!allowed.includes(fullPrep.min_subscription) && req.user.role !== 'admin') {
            return res.status(403).json({ success: false, message: "Upgrade subscription to access" });
        }
        res.status(200).json({ success: true, data: fullPrep });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const updatePrepLesson = async (req, res) => {
    try {
        const { id } = req.params;
        const { error, value } = updateLessonSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        const updated = await prepModel.updatePreparation(id, value);
        if (!updated) return res.status(404).json({ success: false, message: "Lesson not found" });
        res.status(200).json({ success: true, data: updated });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const deletePrepLesson = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await prepModel.deletePreparation(id);
        if (!deleted) return res.status(404).json({ success: false, message: "Lesson not found" });
        res.status(200).json({ success: true, message: "Deleted" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// ==================== PRACTICE MODE ====================

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

// ==================== STUDY PLAN ====================

export const createStudyPlan = async (req, res) => {
    const client = await pool.connect();
    try {
        const { duration_days, target_band } = req.body;
        const planData = await generateStudyPlan(req.user.id, duration_days, target_band);
        await client.query("BEGIN");
        const plan = await studyPlanModel.createStudyPlan({
            user_id: req.user.id, title: planData.title,
            target_band: planData.target_band,
            start_date: planData.start_date, end_date: planData.end_date
        });
        const items = planData.items.map(item => ({ ...item, plan_id: plan.id }));
        await studyPlanModel.addStudyPlanItems(plan.id, items, client);
        await client.query("COMMIT");
        res.status(201).json({ success: true, data: { planId: plan.id } });
    } catch (error) {
        await client.query("ROLLBACK");
        res.status(500).json({ success: false, message: error.message });
    } finally {
        client.release();
    }
};

export const getTodayStudyPlan = async (req, res) => {
    try {
        const items = await studyPlanModel.getTodayPlanItems(req.user.id);
        res.status(200).json({ success: true, data: items });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const completePlanItem = async (req, res) => {
    try {
        const { item_id } = req.params;
        const result = await studyPlanModel.markItemComplete(item_id);
        res.status(200).json({ success: true, data: result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// ==================== ANALYTICS & RECOMMENDATIONS ====================

export const getWeaknessReport = async (req, res) => {
    try {
        const report = await analyzeWeakness(req.user.id);
        res.status(200).json({ success: true, data: report });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const getRecommendations = async (req, res) => {
    try {
        const recs = await generateRecommendations(req.user.id);
        res.status(200).json({ success: true, data: recs });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};