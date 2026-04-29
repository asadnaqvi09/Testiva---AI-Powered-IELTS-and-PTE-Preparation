import express from 'express';
import * as testController from './test.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../middleware/role.middleware.js';
import { requireSubscription } from '../../middleware/subscription.middleware.js';

const router = express.Router();

// Admin routes
router.post('/create-full-test', authenticate, authorizeRoles('admin'), testController.createFullTest);
router.get('/all-tests', authenticate, authorizeRoles('admin'), testController.fetchTests);
router.delete('/:id', authenticate, authorizeRoles('admin'), testController.deleteTest);
router.put('/:id/header', authenticate, authorizeRoles('admin'), testController.updateTestHeaderByID);
router.put('/questions/:id', authenticate, authorizeRoles('admin'), testController.updateTestQuestionByID);

// User routes (with subscription filter)
router.get('/available', authenticate, testController.fetchAvailableTests);
router.get('/:id', authenticate, testController.getTestById);

export default router;