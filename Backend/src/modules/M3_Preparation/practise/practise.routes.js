import express from "express";
import * as practiseController from "./practise.controller.js";
import { authenticate } from "../../../middleware/auth.middleware.js";
import { requireSubscription } from "../../../middleware/subscription.middleware.js";

const router = express.Router();
router.post("/practice/start", authenticate, requireSubscription("free", "basic", "premium"), practiseController.startPractice);
router.post("/practice/answer", authenticate, requireSubscription("free", "basic", "premium"), practiseController.submitPracticeAnswer);
router.post("/practice/:session_id/complete", authenticate, requireSubscription("free", "basic", "premium"), practiseController.completePractice);
router.get("/practice/history", authenticate, requireSubscription("free", "basic", "premium"), practiseController.getPracticeHistory);

export default router;