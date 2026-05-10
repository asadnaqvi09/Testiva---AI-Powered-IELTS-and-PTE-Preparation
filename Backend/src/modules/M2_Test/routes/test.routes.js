import express from 'express';
import * as testController from '../controller/test.controller.js';
import { authenticate } from '../../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../../middleware/role.middleware.js';

const router = express.Router();

// Admin Routes
router.post('/create-full-test', authenticate, authorizeRoles('admin'), testController.createFullTest);
router.get('/all-tests', authenticate, authorizeRoles('admin'), testController.fetchTests);
router.get('/:id', authenticate, authorizeRoles('admin'), testController.getTestById);
router.put('/header/:id', authenticate, authorizeRoles('admin'), testController.updateTestHeaderByID);
router.put('/questions', authenticate, authorizeRoles('admin'), testController.addQuestionToSection);
router.put('/questions/:id', authenticate, authorizeRoles('admin'), testController.updateTestQuestionByID);
router.delete('/questions/:id', authenticate, authorizeRoles('admin'), testController.deleteQuestionFromSection);
router.delete('/:id', authenticate, authorizeRoles('admin'), testController.deleteTest);

// User Routes
router.get('/available', authenticate, testController.fetchAvailableTests);

export default router;