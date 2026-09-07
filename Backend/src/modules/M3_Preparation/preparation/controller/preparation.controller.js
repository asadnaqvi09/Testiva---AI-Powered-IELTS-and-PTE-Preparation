import pool from "../../../../config/db.js";
import * as prepModel from "../model/preparation.model.js";
import {
    createPreparationSchema,
    updatePreparationSchema,
    preparationFilterSchema
} from "../validator/preparation.validator.js";
import { findUserById } from "../../../M1_Identity/user.model.js";
import { getAllowedExamTypes, canAccessExamType, resolveUnlockedExam } from "../../../../utils/helpers.js";

const handleServerError = (res, error) => {
    console.error(error);
    return res.status(500).json({
        success: false,
        message: "Internal server error"
    });
};

const loadAccessUser = async (req) => {
    const user = await findUserById(req.user.id);
    if (!user) return null;
    return {
        ...user,
        unlocked_exam: resolveUnlockedExam(user),
        allowedExamTypes: getAllowedExamTypes(user),
    };
};

export const createPrepLesson = async (req, res) => {
    const client = await pool.connect();
    try {
        const { error, value } = createPreparationSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                success: false,
                message: error.details[0].message
            });
        }
        const { parts, media, ...headerData } = value;
        await client.query("BEGIN");
        const header = await prepModel.createPreparationHeader(headerData, client);
        for (const part of parts) {
            await prepModel.createPrepPart({
                prep_id: header.id,
                ...part
            }, client);
        }
        if (media && media.length > 0) {
            for (const file of media) {
                await prepModel.createPrepMedia({
                    prep_id: header.id,
                    ...file
                }, client);
            }
        }
        await client.query("COMMIT");
        return res.status(201).json({
            success: true,
            message: "Preparation created successfully",
            data: { id: header.id }
        });
    } catch (error) {
        await client.query("ROLLBACK");
        return handleServerError(res, error);
    } finally {
        client.release();
    }
};

export const updatePrepLesson = async (req, res) => {
    const client = await pool.connect();
    try {
        const { error, value } = updatePreparationSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                success: false,
                message: error.details[0].message
            });
        }
        const prepId = req.params.id;
        const { parts, media, ...headerData } = value;
        await client.query("BEGIN");
        const updatedHeader = await prepModel.updatePreparationHeader(prepId, headerData, client);
        if (!updatedHeader) {
            await client.query("ROLLBACK");
            return res.status(404).json({
                success: false,
                message: "Preparation not found"
            });
        }
        if (parts !== undefined && parts.length > 0) {
            await prepModel.deletePrepParts(prepId, client);
            for (const part of parts) {
                await prepModel.createPrepPart({
                    prep_id: prepId,
                    ...part
                }, client);
            }
        }
        if (media !== undefined && media.length > 0) {
            await prepModel.deletePrepMedia(prepId, client);
            for (const file of media) {
                await prepModel.createPrepMedia({
                    prep_id: prepId,
                    ...file
                }, client);
            }
        }
        await client.query("COMMIT");
        return res.status(200).json({
            success: true,
            message: "Preparation updated successfully"
        });
    } catch (error) {
        await client.query("ROLLBACK");
        return handleServerError(res, error);
    } finally {
        client.release();
    }
};

export const getPrepLessons = async (req, res) => {
    try {
        const { error, value } = preparationFilterSchema.validate(req.query);
        if (error) {
            return res.status(400).json({
                success: false,
                message: error.details[0].message
            });
        }
        const accessUser = await loadAccessUser(req);
        if (!accessUser) {
            return res.status(404).json({ success: false, message: "User not found" });
        }
        const role = accessUser.role;
        let activeTestType = value.test_type;
        if (role !== "admin") {
            const allowed = accessUser.allowedExamTypes;
            if (!allowed.length) {
                return res.status(403).json({
                    success: false,
                    message: "Please select your learning preference to continue"
                });
            }
            if (activeTestType) {
                const requested = activeTestType.trim().toUpperCase();
                if (!allowed.includes(requested)) {
                    return res.status(403).json({
                        success: false,
                        message: `Access denied. Your unlocked track does not include ${requested}.`
                    });
                }
                activeTestType = requested;
            } else if (allowed.length === 1) {
                activeTestType = allowed[0];
            }
        }
        const preparations = await prepModel.getAllPreparations(
            activeTestType,
            value.section,
            value.search
        );
        return res.status(200).json({
            success: true,
            count: preparations.length,
            data: preparations
        });
    } catch (error) {
        return handleServerError(res, error);
    }
};

export const getPrepDetails = async (req, res) => {
    try {
        const fullPrep = await prepModel.getFullPrepByID(req.params.id);
        if (!fullPrep) {
            return res.status(404).json({
                success: false,
                message: "Preparation not found"
            });
        }
        const accessUser = await loadAccessUser(req);
        if (!accessUser) {
            return res.status(404).json({ success: false, message: "User not found" });
        }
        if (accessUser.role !== "admin") {
            if (!accessUser.allowedExamTypes.length) {
                return res.status(403).json({ success: false, message: "Please set your track preference first." });
            }
            if (!canAccessExamType(accessUser, fullPrep.test_type)) {
                return res.status(403).json({
                    success: false,
                    message: "Access denied. Target content is locked to your unlocked exam track."
                });
            }
        }
        return res.status(200).json({
            success: true,
            data: fullPrep
        });
    } catch (error) {
        return handleServerError(res, error);
    }
};

export const deletePrepLesson = async (req, res) => {
    const client = await pool.connect();
    try {
        await client.query("BEGIN");
        const deleted = await prepModel.deletePreparation(req.params.id, client);
        if (!deleted) {
            await client.query("ROLLBACK");
            return res.status(404).json({
                success: false,
                message: "Preparation not found"
            });
        }
        await client.query("COMMIT");
        return res.status(200).json({
            success: true,
            message: "Preparation deleted successfully"
        });
    } catch (error) {
        await client.query("ROLLBACK");
        return handleServerError(res, error);
    } finally {
        client.release();
    }
};