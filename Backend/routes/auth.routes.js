import express from 'express';
import * as authController from '../controllers/auth.controller.js';
import * as rateLimiter from '../middleware/rateLimiter.middleware.js';
const Router = express.Router();

Router.post('/register', rateLimiter.authLimiter ,authController.registerUser);
Router.post('/login', rateLimiter.authLimiter ,authController.loginUser);
Router.post('/guest', rateLimiter.authLimiter ,authController.guestAccess);
Router.post('/logout', rateLimiter.authLimiter, authController.logoutUser);
export default Router;