import express from "express";
import * as prepController from "./preparation.controller.js";
import { authenticate } from "../../../middleware/auth.middleware.js";
import { authorizeRoles } from "../../../middleware/role.middleware.js";
import { fileUpload } from '../../../middleware/upload.middleware.js';
import { uploadFileController } from './file.service.js';

const router = express.Router();

router.get("/", authenticate, prepController.getPrepLessons);
router.get("/lesson/:id", authenticate, prepController.getPrepDetails);
router.post("/create-lesson", authenticate, authorizeRoles("admin"), prepController.createPrepLesson);
router.put("/lesson/:id", authenticate, authorizeRoles("admin"), prepController.updatePrepLesson);
router.delete("/lesson/:id", authenticate, authorizeRoles("admin"), prepController.deletePrepLesson);
router.post("/upload-pdf", authenticate, authorizeRoles("admin"), fileUpload.single("file"), uploadFileController);

export default router;