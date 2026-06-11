import express from "express";
import { authenticate } from "../../../../middleware/auth.middleware.js";
import { authorizeRoles } from "../../../../middleware/role.middleware.js";
import * as userController from "../controller/user.controller.js";
import { upload } from "../../../../middleware/upload.middleware.js";
const Router = express.Router();

Router.get("/profile", authenticate, authorizeRoles("user", "admin"), userController.getProfileController);
Router.put("/profile", authenticate, authorizeRoles("user", "admin"), userController.updateProfileController);
Router.get("/results", authenticate, authorizeRoles("user"), userController.getAllResults);
Router.put("/password", authenticate, authorizeRoles("user", "admin"), userController.changePasswordController);
Router.post("/avatar", authenticate, authorizeRoles("user", "admin"), upload.single("avatar"), userController.uploadAvatarController);
Router.put("/fcm-token", authenticate, authorizeRoles("user", "admin"), userController.updateFcmTokenController);
Router.post("/request-preference-change", authenticate, authorizeRoles("user"), userController.requestPreferenceChangeController);

export default Router;
