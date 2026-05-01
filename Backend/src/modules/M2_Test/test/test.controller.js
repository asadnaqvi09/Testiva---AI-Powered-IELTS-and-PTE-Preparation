import pool from "../../../config/db.js";
import * as testModel from "../test.model.js";
import { createTestSchema, updateHeaderSchema, updateQuestionSchema, addQuestionSchema } from "./test.validator.js";
import cloudinary from "../../../config/cloudinary.js";

export const createFullTest = async (req, res) => {
    const client = await pool.connect();
    try {
        const { error, value } = createTestSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        const { title, exam_type, is_full_mock, sections } = value;
        const adminId = req.user.id;
        await client.query("BEGIN");
        const newTest = await testModel.createTest(
            { title, exam_type, is_full_mock, total_time_minutes: 0, created_by: adminId }, 
            client
        );
        for (const section of sections) {
            const newSection = await testModel.createSection({
                test_id: newTest.id,
                section_name: section.section_name,
                time_limit_minutes: section.time_limit_minutes,
                order_number: section.order_number,
                instructions: section.instructions
            }, client);

            if (section.questions && section.questions.length > 0) {
                const questionsData = section.questions.map(q => ({
                    ...q,
                    section_id: newSection.id
                }));
                await testModel.createQuestionsBatch(questionsData, client);
            }
        }
        await client.query("COMMIT");
        res.status(201).json({ success: true, data: { id: newTest.id, title } });
    } catch (error) {
        await client.query("ROLLBACK");
        res.status(500).json({ success: false, message: error.message });
    } finally {
        client.release();
    }
};

export const fetchAvailableTests = async (req, res) => {
    try {
        const { subscription, role } = req.user;
        if (role === 'admin') {
            const tests = await testModel.getAllTests(100, 0);
            return res.status(200).json({ success: true, data: tests });
        }
        let examTypes = ['IELTS'];
        let allowedSections = null;
        if (subscription === 'free') {
            allowedSections = ['Reading', 'Writing'];
        } else if (subscription === 'basic') {
            examTypes = ['IELTS'];
        } else if (subscription === 'premium') {
            examTypes = ['IELTS', 'PTE'];
        }
        const tests = await testModel.getTestsByFilters(examTypes, allowedSections);
        res.status(200).json({ success: true, data: tests });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching available tests" });
    }
};

export const fetchTests = async (req, res) => {
    try {
        const page = Math.max(parseInt(req.query.page) || 1, 1);
        const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
        const offset = (page - 1) * limit;
        const examType = req.query.exam_type || null;
        const tests = await testModel.getAllTests(limit, offset, examType);
        res.status(200).json({ success: true, count: tests.length, data: tests });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching tests" });
    }
};

export const getTestById = async (req, res) => {
    try {
        const testDetails = await testModel.getFullTestDetails(req.params.id);
        if (!testDetails) return res.status(404).json({ success: false, message: "Test not found" });
        if (req.user.role !== 'admin') {
            testDetails.sections.forEach(section => {
                section.questions.forEach(q => {
                    delete q.correct_answer;
                    delete q.marks;
                });
            });
        }
        res.status(200).json({ success: true, data: testDetails });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const updateTestHeaderByID = async (req, res) => {
    try {
        const { error, value } = updateHeaderSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        const updatedTest = await testModel.updateTestHeader(req.params.id, value);
        if (!updatedTest) return res.status(404).json({ success: false, message: "Test not found" });
        res.status(200).json({ success: true, data: updatedTest });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const updateTestQuestionByID = async (req, res) => {
    try {
        const { error, value } = updateQuestionSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        const updatedQuestion = await testModel.updateQuestionById(req.params.id, value);
        if (!updatedQuestion) return res.status(404).json({ success: false, message: "Question not found" });
        res.status(200).json({ success: true, data: updatedQuestion });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const deleteTest = async (req, res) => {
    try {
        const testDetails = await testModel.getFullTestDetails(req.params.id);
        if (!testDetails) return res.status(404).json({ success: false, message: "Test not found" });
        const audioUrls = [];
        testDetails.sections.forEach(s => s.questions.forEach(q => {
            if (q.audio_url) audioUrls.push(q.audio_url);
        }));
        for (const url of audioUrls) {
            try {
                const parts = url.split('/');
                const filename = parts.pop().split('.')[0];
                const folder = parts.slice(parts.indexOf('upload') + 2).join('/');
                const publicId = folder ? `${folder}/${filename}` : filename;
                await cloudinary.uploader.destroy(publicId);
            } catch (e) { /* Silently fail if cloud delete fails */ }
        }
        await testModel.deleteTestById(req.params.id);
        res.status(200).json({ success: true, message: "Test deleted successfully" });
    } catch (error) {
        console.log(error);
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const addQuestionToSection = async (req,res) => {
    try {
        const {error,value} = addQuestionSchema.validate(req.body);
        if (error) return res.status(400).json({
            success : false,
            message : error.details[0].message
        });
        const newQuestion = await testModel.createSingleQuestion(value);
        res.status(201).json({ success: true, data: newQuestion });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error adding question: " + error.message });
    }
}

export const deleteQuestionFromSection = async (req, res) => {
    try {
        const { id } = req.params;
        const question = await testModel.getQuestionById(id);
        if (!question) return res.status(404).json({ success: false, message: "Question not found" });
        if (question.audio_url) {
            try {
                const parts = question.audio_url.split('/');
                const filename = parts.pop().split('.')[0];
                const folder = parts.slice(parts.indexOf('upload') + 2).join('/');
                const publicId = folder ? `${folder}/${filename}` : filename;
                await cloudinary.uploader.destroy(publicId);
            } catch (cloudErr) {
                console.error("Cloudinary delete failed:", cloudErr);
            }
        }
        await testModel.deleteQuestionById(id);
        res.status(200).json({ success: true, message: "Question deleted successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};