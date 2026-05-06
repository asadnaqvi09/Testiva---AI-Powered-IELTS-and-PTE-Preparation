import pool from "../../../config/db.js";
import * as studyPlanModel from "../studyPlan.model.js";
import { generateRecommendations } from "../../../utils/recommendationEngine.js";
import { generateStudyPlan } from "../../../utils/studyPlan.js";
import { analyzeWeakness } from "../../../utils/weaknessAnalyzer.js";

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