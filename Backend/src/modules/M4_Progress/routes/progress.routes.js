import express from "express";
import * as progressController from "../controller/progress.controller.js";
import { authenticate } from "../../../middleware/auth.middleware.js";
import { writeLimiter } from "../../../middleware/rateLimiter.middleware.js";

const router = express.Router();

router.post("/submit-test", writeLimiter, authenticate, progressController.submitTest);
router.get("/my-stats", authenticate, progressController.getMyStats);
router.get("/result/:attempt_id", authenticate, progressController.getTestResult);

export default router;