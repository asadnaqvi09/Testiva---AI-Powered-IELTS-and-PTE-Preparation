import express from "express";
import { authenticate } from "../../../../middleware/auth.middleware.js";
import { authorizeRoles } from "../../../../middleware/role.middleware.js";
import * as userController from "../controller/user.controller.js";

const router = express.Router();

router.post("/", authenticate, authorizeRoles("user", "admin"), userController.submitAppFeedbackController);

export default router;
