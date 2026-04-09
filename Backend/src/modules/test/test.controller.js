import pool from "../../config/db.js";
import * as testModel from "../../models/test.model.js";
import { createTestSchema } from "./test.validator.js";

export const createFullTest = async (req, res) => {
    const client = await pool.connect();
    try {
        const { error, value } = createTestSchema.validate(req.body);
        if (error) {
            return res.status(400).json({ success: false, message: error.details[0].message });
        }
        const { title, exam_type, is_full_mock, total_time_minutes, sections } = value;
        const adminId = req.user.id;
        await client.query("BEGIN");
        const newTest = await testModel.createTest(
            { title, exam_type, is_full_mock, total_time_minutes, created_by: adminId },
            client
        );
        const testId = newTest.id;
        for (const section of sections) {
            const newSection = await testModel.createSection(
                {
                    test_id: testId,
                    section_name: section.section_name,
                    time_limit_minutes: section.time_limit_minutes,
                    order_number: section.order_number,
                    instructions: section.instructions
                },
                client
            );
            const sectionId = newSection.id;
            for (const q of section.questions) {
                await testModel.createQuestion(
                    {
                        section_id: sectionId,
                        question_type: q.question_type,
                        passage_text: q.passage_text,
                        question_text: q.question_text,
                        options: q.options,
                        correct_answer: q.correct_answer,
                        audio_url: q.audio_url,
                        order_number: q.order_number,
                        marks: q.marks
                    },
                    client
                );
            }
        }
        await client.query("COMMIT");
        res.status(201).json({
            success: true,
            message: "Mock Test created successfully with all sections and questions",
            data: { testId: testId, title: title }
        });
    } catch (error) {
        await client.query("ROLLBACK");
        console.error("Error in createFullTest Transaction:", error);
        res.status(500).json({ success: false, message: "Internal Server Error: Test creation failed" });
    } finally {
        client.release();
    }
};

export const fetchTests = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const offset = (page - 1) * limit;
        const tests = await testModel.getAllTests(limit, offset);
        res.status(200).json({ success: true, count: tests.length, data: tests });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching tests" });
    }
};

export const deleteTest = async (req,res) => {
    try {
        const testId = req.params.id;
        if(!testId) {
            return res.status(400).json({
                success: false,
                message: "No Test Avaiable with provided ID"
            })
        } else {
            await testModel.deleteTestById(testId);
            res.status(200).json({
                success: true,
                message: "Test deleted successfully"
            })
        }
    } catch (error) {
        console.error("Error In deleteTest Controller : ", error);
        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })
    }
};

export const getTestById = async (req,res) => {
    try {
        const { id } = req.params;
        const testDetails = await testModel.getFullTestDetails(id);
        if (!testDetails) {
            return res.status(404).json({
                success: false,
                message: "Test is not available with provided ID"
            })
        }
        return res.status(200).json({
            success: true,
            message: "Test details fetched successfully",
            data: testDetails
        })
    } catch (error) {
        console.error("Error In getTestById Controller : ", error);
        return res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })
    }
};

export const updateTestHeaderByID = async (req,res) => {
    try {
        const { id } = req.params;
        if(!id) {
            return res.status(400).json({
                success: false,
                message: "No Test Available with provided ID"
            })
        };
        const updateTest = await testModel.updateTestHeader(id, req.body);
        res.status(200).json({
            success: true,
            message: `${updateTest.title} content updated successfully`,
            data : updateTest
        })
    } catch (error) {
        console.error("Error In updateTestHeaderByID Contoller : ", error);
        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })   
    }
};

export const updateTestQuestionByID = async (req,res) => {
    try {
        const {id} = req.params;
        if(!id) {
            return res.status(400).json({
                success: false,
                message: "No Test Available with provided ID"
            })
        };
        const updatedQuestion = await testModel.updateQuestionById(id,req.body);
        res.status(200).json({
            success: true,
            message: `Question content updated successfully`,
            data : updatedQuestion
        })
    } catch (error) {
        console.error("Error In updateTestQuestionByID Controller : ", error);
        res.status(500).json({
            success: false,
            message: "Internal Server Error"
        })
    }
};