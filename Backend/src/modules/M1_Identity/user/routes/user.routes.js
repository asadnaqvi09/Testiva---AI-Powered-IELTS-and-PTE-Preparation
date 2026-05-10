import express from "express";
import { authenticate } from "../../../../middleware/auth.middleware.js";
import { authorizeRoles } from "../../../../middleware/role.middleware.js";
import * as userController from "../controller/user.controller.js";
import { upload } from "../../../../middleware/upload.middleware.js";
const Router = express.Router();

Router.get("/profile", authenticate, authorizeRoles("user", "admin"), userController.getProfileController);
Router.put("/profile", authenticate, authorizeRoles("user", "admin"), userController.updateProfileController);
Router.put("/password", authenticate, authorizeRoles("user", "admin"), userController.changePasswordController);
Router.post("/avatar", authenticate, authorizeRoles("user", "admin"), upload.single("avatar"), userController.uploadAvatarController);
Router.put("/fcm-token", authenticate, authorizeRoles("user", "admin"), userController.updateFcmTokenController);

export default Router;