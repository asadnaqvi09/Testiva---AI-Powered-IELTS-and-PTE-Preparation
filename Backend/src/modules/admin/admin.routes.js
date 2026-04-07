import express from 'express';
import * as adminController from './admin.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../middleware/role.middleware.js';

const router = express.Router();

router.get('/stats', authenticate, authorizeRoles('admin') , adminController.getDashboardStats);
router.get('/users', authenticate, authorizeRoles('admin') , adminController.getAllUsers);
router.put('/users/subscription', authenticate, authorizeRoles('admin') , adminController.updateUserSubscription);
router.post('/content/reading', authenticate, authorizeRoles('admin') , adminController.readingController);
router.post('/content/listening', authenticate, authorizeRoles('admin') , adminController.listeningController);
router.get('/test/analytics', authenticate, authorizeRoles('admin') , adminController.analyticsController);

export default router;