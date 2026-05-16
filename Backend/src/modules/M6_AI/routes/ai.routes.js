import express from "express";
import { authenticate } from "../../../middleware/auth.middleware.js";
import { aiLimiter } from "../../../middleware/rateLimiter.middleware.js";
import * as aiController from "../controller/ai.controller.js";

const router = express.Router();

router.post("/evaluate/writing", aiLimiter, authenticate, aiController.evaluateSubmission);
router.post("/evaluate/speaking", aiLimiter, authenticate, aiController.evaluateSpeaking);
router.post("/response-feedback", aiLimiter, authenticate, aiController.patchResponseAiFeedback);

export default router;
