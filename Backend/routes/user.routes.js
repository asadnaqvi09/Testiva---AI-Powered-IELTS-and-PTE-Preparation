import express from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { authorizeRoles } from "../middleware/role.middleware.js";
import * as userController from "../controllers/user.controller.js";

const Router = express.Router();

Router.get('/profile', authenticate , authorizeRoles("user","admin") , userController.getProfile);
Router.put('/profile', authenticate , authorizeRoles("user","admin") , userController.updateProfile);

export default Router;