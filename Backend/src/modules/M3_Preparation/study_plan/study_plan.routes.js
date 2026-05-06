import express from "express";
import * as studyController from "./study_plan.controller.js";
import { authenticate } from "../../../middleware/auth.middleware.js";
import { requireSubscription } from "../../../middleware/subscription.middleware.js";

const router = express.Router();

// User: Study Plan
router.post("/create-study-plan", authenticate, requireSubscription("basic", "premium"), studyController.createStudyPlan);
router.get("/study-plan/today", authenticate, requireSubscription("basic", "premium"), studyController.getTodayStudyPlan);
router.put("/study-plan/items/:item_id/complete", authenticate, requireSubscription("basic", "premium"), studyController.completePlanItem);

// User: Analytics
router.get("/weakness-report", authenticate, requireSubscription("free", "basic", "premium"), studyController.getWeaknessReport);
router.get("/recommendations", authenticate, requireSubscription("free", "basic", "premium"), studyController.getRecommendations);

export default router;