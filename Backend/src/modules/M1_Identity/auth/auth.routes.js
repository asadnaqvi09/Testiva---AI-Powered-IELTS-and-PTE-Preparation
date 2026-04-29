import express from 'express';
import * as authController from './auth.controller.js';
import * as rateLimiter from '../../../middleware/rateLimiter.middleware.js';
import { authenticate } from '../../../middleware/auth.middleware.js';

const Router = express.Router();

Router.post('/register', rateLimiter.authLimiter, authController.registerUser);
Router.post('/login', rateLimiter.authLimiter, authController.loginUser);
Router.post('/verify-otp', rateLimiter.otpLimiter, authController.verifyOTP);
Router.post('/resend-otp', rateLimiter.otpLimiter, authController.resendOTP);
Router.post('/forgot-password', rateLimiter.authLimiter, authController.forgotPassword);
Router.post('/reset-password', rateLimiter.authLimiter, authController.resetPassword);
Router.post('/google', rateLimiter.authLimiter, authController.googleAuth);
Router.post('/refresh-token', rateLimiter.authLimiter, authController.refreshAccessToken);
Router.post('/logout', authenticate, rateLimiter.authLimiter, authController.logoutUser);
Router.post('/logout-all', authenticate, rateLimiter.authLimiter, authController.logoutAllUserDevices);

export default Router;