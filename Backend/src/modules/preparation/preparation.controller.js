import pool from "../../config/db.js";
import * as prepModel from "../../models/preparation.model.js";

export const createPrepLesson = async (req, res) => {
    const client = await pool.connect();
    try {
        const { title, test_type, section, summary, status, parts } = req.body;
        const created_by = req.user.id;
        await client.query('BEGIN');
        const header = await prepModel.createPreparationHeader({
            title, test_type, section, summary, status, created_by
        }, client);
        if (parts && parts.length > 0) {
            for (const part of parts) {
                await prepModel.createPreparationPart({
                    lesson_id: header.id,
                    part_title: part.part_title,
                    part_content: part.part_content,
                    order_number: part.order_number
                }, client);
            }
        }
        await client.query('COMMIT');
        res.status(201).json({
            success: true,
            message: "Preparation lesson and parts created successfully",
            data: { id: header.id }
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Prep Creation Error:", error);
        res.status(500).json({ success: false, message: error.message });
    } finally {
        client.release();
    }
};

export const getPrepLessons = async (req, res) => {
    try {
        const filters = {
            test_type: req.query.test_type,
            section: req.query.section,
            status: 'published'
        };
        const lessons = await prepModel.getAllPreparations(filters);
        res.status(200).json({ success: true, count: lessons.length, data: lessons });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const getPrepDetails = async (req, res) => {
    try {
        const { id } = req.params;
        const fullPrep = await prepModel.getFullPrepByID(id);
        if (!fullPrep) {
            return res.status(404).json({ success: false, message: "Preparation lesson not found" });
        }
        res.status(200).json({ success: true, data: fullPrep });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const deletePrepLesson = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await prepModel.deletePreparation(id);
        if (!deleted) {
            return res.status(404).json({ success: false, message: "Lesson not found" });
        }
        res.status(200).json({ success: true, message: "Lesson deleted successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};