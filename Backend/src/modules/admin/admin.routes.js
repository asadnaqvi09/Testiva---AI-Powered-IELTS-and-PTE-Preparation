import express from 'express';
import * as adminController from './admin.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../middleware/role.middleware.js';

const router = express.Router();

router.get('/stats', authenticate, authorizeRoles('admin') , adminController.getStatsController);
router.get('/users', authenticate, authorizeRoles('admin') , adminController.getUsersController);
router.put('/users/subscription', authenticate, authorizeRoles('admin') , adminController.subscriptionController);
router.post('/content/reading', authenticate, authorizeRoles('admin') , adminController.readingController);
router.post('/content/listening', authenticate, authorizeRoles('admin') , adminController.listeningController);
router.get('/test/analytics', authenticate, authorizeRoles('admin') , adminController.analyticsController);

export default router;