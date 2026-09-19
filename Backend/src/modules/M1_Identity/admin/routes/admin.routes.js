import express from 'express';
import * as adminController from '../controller/admin.controller.js';
import { authenticate } from '../../../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../../../middleware/role.middleware.js';

const router = express.Router();

router.get('/stats', authenticate, authorizeRoles('admin') , adminController.getDashboardStats);
router.get('/analytics', authenticate, authorizeRoles('admin'), adminController.getAnalytics);
router.get('/search', authenticate, authorizeRoles('admin'), adminController.searchAdmin);
router.get('/users', authenticate, authorizeRoles('admin') , adminController.getAllUsers);
router.put('/users/subscription', authenticate, authorizeRoles('admin') , adminController.updateUserSubscription);

export default router;