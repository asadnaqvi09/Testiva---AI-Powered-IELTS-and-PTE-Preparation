import express from "express";
import { upload } from "../../../middleware/upload.middleware.js";
import * as testController from "../controller/test.controller.js";
import { authenticate } from "../../../middleware/auth.middleware.js";
import { authorizeRoles } from "../../../middleware/role.middleware.js";
import { apiLimiter, writeLimiter } from "../../../middleware/rateLimiter.middleware.js";

const router = express.Router();
router.use(apiLimiter);

router.get("/admin/mocks", authenticate, authorizeRoles("admin"), testController.fetchAdminMocksDashboard);
router.get("/all-tests", authenticate, authorizeRoles("admin"), testController.fetchAdminMocksDashboard);
router.get("/mobile/dashboard", authenticate, testController.fetchMobileMocksDashboard);
router.post(
  "/mocks/assets",
  authenticate,
  authorizeRoles("admin"),
  upload.single("file"),
  testController.uploadTestAsset,
);
router.post("/create-full-test", authenticate, authorizeRoles("admin"), writeLimiter, testController.createFullTest);
router.put("/:id/nested", authenticate, authorizeRoles("admin"), writeLimiter, testController.upsertTestNested);
router.put("/header/:id", authenticate, authorizeRoles("admin"), writeLimiter, testController.updateTestHeaderByID);
router.put("/questions", authenticate, authorizeRoles("admin"), writeLimiter, testController.addQuestionToSection);
router.put("/questions/:id", authenticate, authorizeRoles("admin"), writeLimiter, testController.updateTestQuestionByID);
router.delete("/questions/:id", authenticate, authorizeRoles("admin"), writeLimiter, testController.deleteQuestionFromSection);
router.delete("/:id", authenticate, authorizeRoles("admin"), writeLimiter, testController.deleteTest);
router.get("/available", authenticate, testController.fetchAvailableTests);
router.get("/:id/preview", authenticate, testController.getTestPreview);
router.get("/:id/runtime", authenticate, testController.getTestRuntime);
router.get("/:id", authenticate, testController.getTestById);

export default router;