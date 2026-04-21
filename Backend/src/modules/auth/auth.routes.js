import express from 'express';
import * as authController from './auth.controller.js';
import * as rateLimiter from '../../middleware/rateLimiter.middleware.js';
import { authenticate } from '../../middleware/auth.middleware.js';
const Router = express.Router();

Router.post('/register', rateLimiter.authLimiter ,authController.registerUser);
Router.post('/login', rateLimiter.authLimiter ,authController.loginUser);
Router.post('/guest', rateLimiter.authLimiter ,authController.guestAccess);
Router.post('/logout', authenticate ,rateLimiter.authLimiter, authController.logoutUser);
Router.post('/google', rateLimiter.authLimiter, authController.googleAuth);
Router.post('/verifyOTP', rateLimiter.authLimiter, authController.verifyOTP);
Router.post('/resendOTP', rateLimiter.otpLimiter, authController.resendOTP);
Router.post('/forgot-password', rateLimiter.authLimiter, authController.forgotPassword);
Router.post('/reset-password', rateLimiter.authLimiter, authController.resetPassword);
export default Router;