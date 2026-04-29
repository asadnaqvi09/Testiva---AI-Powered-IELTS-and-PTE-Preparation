import express from "express";
import * as prepController from "./preparation.controller.js";
import { authenticate } from "../../middleware/auth.middleware.js";
import { authorizeRoles } from "../../middleware/role.middleware.js";
import { requireSubscription } from "../../middleware/subscription.middleware.js";

const router = express.Router();

// User: Lessons (subscription filtered)
router.get("/preparations", authenticate, requireSubscription("free", "basic", "premium"), prepController.getPrepLessons);
router.get("/preparations/:id", authenticate, requireSubscription("free", "basic", "premium"), prepController.getPrepDetails);

// User: Practice Mode
router.post("/practice/start", authenticate, requireSubscription("free", "basic", "premium"), prepController.startPractice);
router.post("/practice/answer", authenticate, requireSubscription("free", "basic", "premium"), prepController.submitPracticeAnswer);
router.post("/practice/:session_id/complete", authenticate, requireSubscription("free", "basic", "premium"), prepController.completePractice);
router.get("/practice/history", authenticate, requireSubscription("free", "basic", "premium"), prepController.getPracticeHistory);

// User: Study Plan
router.post("/study-plan", authenticate, requireSubscription("basic", "premium"), prepController.createStudyPlan);
router.get("/study-plan/today", authenticate, requireSubscription("basic", "premium"), prepController.getTodayStudyPlan);
router.put("/study-plan/items/:item_id/complete", authenticate, requireSubscription("basic", "premium"), prepController.completePlanItem);

// User: Analytics
router.get("/weakness-report", authenticate, requireSubscription("free", "basic", "premium"), prepController.getWeaknessReport);
router.get("/recommendations", authenticate, requireSubscription("free", "basic", "premium"), prepController.getRecommendations);

// Admin: Lesson Management
router.post("/preparations", authenticate, authorizeRoles("admin"), prepController.createPrepLesson);
router.put("/preparations/:id", authenticate, authorizeRoles("admin"), prepController.updatePrepLesson);
router.delete("/preparations/:id", authenticate, authorizeRoles("admin"), prepController.deletePrepLesson);

export default router;