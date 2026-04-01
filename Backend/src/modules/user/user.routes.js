import express from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { authorizeRoles } from "../middleware/role.middleware.js";
import * as userController from "../controllers/user.controller.js";
import { uploadAvatar } from "../middleware/upload.middleware.js";
const Router = express.Router();

Router.get('/profile', authenticate , authorizeRoles("user","admin") , userController.getProfileController);
Router.put('/profile', authenticate , authorizeRoles("user","admin") , userController.updateProfileController);
Router.post('/avatar', authenticate, authorizeRoles("user","admin") , uploadAvatar.single("avatar") , userController.uploadAvatarController)

export default Router;