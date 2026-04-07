import express from 'express';
import * as testController from './test.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../middleware/role.middleware.js';

const router = express.Router();

router.post('/create-full-test',authenticate,authorizeRoles('admin'),testController.createFullTest);
router.get('/all-tests',authenticate,authorizeRoles('admin'),testController.fetchTests);
router.delete('/deleteTest/:id', authenticate, authorizeRoles('admin'), testController.deleteTest);
router.get('/getTest/:id', authenticate, testController.getTestById);
router.put('/updateTestHeader/:id', authenticate, authorizeRoles('admin'), testController.updateTestHeaderByID);
router.put('/updateTestQuestion/:id', authenticate, authorizeRoles('admin'), testController.updateTestQuestionByID);

export default router;