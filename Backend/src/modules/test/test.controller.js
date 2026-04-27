import pool from "../../config/db.js";
import * as testModel from "../../models/test.model.js";
import { createTestSchema, updateHeaderSchema, updateQuestionSchema } from "./test.validator.js";
import cloudinary from "../../config/cloudinary.js";

export const createFullTest = async (req, res) => {
    const client = await pool.connect();
    try {
        const { error, value } = createTestSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        
        const { title, exam_type, is_full_mock, total_time_minutes, sections } = value;
        const adminId = req.user.id;
        
        await client.query("BEGIN");
        const newTest = await testModel.createTest(
            { title, exam_type, is_full_mock, total_time_minutes, created_by: adminId }, client
        );
        
        for (const section of sections) {
            const newSection = await testModel.createSection({
                test_id: newTest.id,
                section_name: section.section_name,
                time_limit_minutes: section.time_limit_minutes,
                order_number: section.order_number,
                instructions: section.instructions
            }, client);
            
            if (section.questions.length > 0) {
                const questionsData = section.questions.map(q => ({
                    section_id: newSection.id,
                    question_type: q.question_type,
                    passage_text: q.passage_text,
                    question_text: q.question_text,
                    options: q.options,  // Direct array — model handles JSONB
                    correct_answer: q.correct_answer,
                    audio_url: q.audio_url,
                    order_number: q.order_number,
                    marks: q.marks
                }));
                await testModel.createQuestionsBatch(questionsData, client);
            }
        }
        
        await client.query("COMMIT");
        res.status(201).json({ success: true, message: "Test created successfully", data: { testId: newTest.id, title } });
    } catch (error) {
        await client.query("ROLLBACK");
        res.status(500).json({ success: false, message: "Test creation failed" });
    } finally {
        client.release();
    }
};

export const fetchTests = async (req, res) => {
    try {
        const page = Math.max(parseInt(req.query.page) || 1, 1);
        const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
        const offset = (page - 1) * limit;
        const examType = req.query.exam_type || null;
        const isPublished = req.query.is_published || null;
        const tests = await testModel.getAllTests(limit, offset, examType, isPublished);
        res.status(200).json({ success: true, count: tests.length, page, data: tests });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching tests" });
    }
};

export const fetchAvailableTests = async (req, res) => {
    try {
        const { subscription, role } = req.user;
        if (role === 'admin') {
            const tests = await testModel.getAllTests(100, 0);
            return res.status(200).json({ success: true, data: tests });
        }
        
        let allowedTypes = ['IELTS'];
        if (subscription === 'premium') allowedTypes.push('PTE');
        
        const tests = await testModel.getTestsByExamTypes(allowedTypes);
        res.status(200).json({ success: true, data: tests });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching tests" });
    }
};

export const deleteTest = async (req, res) => {
    try {
        const testId = req.params.id;
        const testDetails = await testModel.getFullTestDetails(testId);
        if (!testDetails) return res.status(404).json({ success: false, message: "Test not found" });
        
        const audioUrls = [];
        testDetails.sections.forEach(s => s.questions.forEach(q => {
            if (q.audio_url) audioUrls.push(q.audio_url);
        }));
        
        audioUrls.forEach(url => {
            try {
                const urlObj = new URL(url);
                const pathParts = urlObj.pathname.split('/');
                const filename = pathParts.pop().split('.')[0];
                const folder = pathParts.slice(pathParts.indexOf('upload') + 2, -1).join('/');
                const publicId = folder ? `${folder}/${filename}` : filename;
                cloudinary.uploader.destroy(publicId).catch(() => {});
            } catch (e) {}
        });
        
        await testModel.deleteTestById(testId);
        res.status(200).json({ success: true, message: "Test deleted successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const getTestById = async (req, res) => {
    try {
        const { id } = req.params;
        const testDetails = await testModel.getFullTestDetails(id);
        if (!testDetails) return res.status(404).json({ success: false, message: "Test not found" });
        
        if (req.user.role !== 'admin') {
            const sanitized = JSON.parse(JSON.stringify(testDetails));
            sanitized.sections.forEach(section => {
                section.questions.forEach(q => {
                    delete q.correct_answer;
                    delete q.marks;
                });
            });
            return res.status(200).json({ success: true, data: sanitized });
        }
        
        res.status(200).json({ success: true, data: testDetails });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const updateTestHeaderByID = async (req, res) => {
    try {
        const { id } = req.params;
        const { error, value } = updateHeaderSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        
        const cleanData = Object.fromEntries(
            Object.entries(value).filter(([_, v]) => v !== undefined)
        );
        
        const updatedTest = await testModel.updateTestHeader(id, cleanData);
        if (!updatedTest) return res.status(404).json({ success: false, message: "Test not found" });
        
        res.status(200).json({ success: true, message: "Test updated successfully", data: updatedTest });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export const updateTestQuestionByID = async (req, res) => {
    try {
        const { id } = req.params;
        const { error, value } = updateQuestionSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        
        const updatedQuestion = await testModel.updateQuestionById(id, value);
        if (!updatedQuestion) return res.status(404).json({ success: false, message: "Question not found" });
        
        res.status(200).json({ success: true, message: "Question updated successfully", data: updatedQuestion });
    } catch (error) {
        res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};