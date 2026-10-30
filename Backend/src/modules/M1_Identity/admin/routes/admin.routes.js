import express from 'express';
import * as adminController from '../controller/admin.controller.js';
import { authenticate } from '../../../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../../../middleware/role.middleware.js';

const router = express.Router();

router.get('/stats', authenticate, authorizeRoles('admin') , adminController.getDashboardStats);
router.get('/analytics', authenticate, authorizeRoles('admin'), adminController.getAnalytics);
router.get('/search', authenticate, authorizeRoles('admin'), adminController.searchAdmin);
router.get('/users', authenticate, authorizeRoles('admin') , adminController.getAllUsers);
router.post('/users', authenticate, authorizeRoles('admin'), adminController.createAdminUser);
router.delete('/users/:id', authenticate, authorizeRoles('admin'), adminController.deleteAdminUser);
router.put('/users/subscription', authenticate, authorizeRoles('admin') , adminController.updateUserSubscription);
router.get('/preference-requests', authenticate, authorizeRoles('admin'), adminController.getPreferenceChangeRequests);
router.post('/preference-requests/approve', authenticate, authorizeRoles('admin'), adminController.approvePreferenceChangeRequest);
// L4 / L6 ops
router.get('/queues/sync-tests', authenticate, authorizeRoles('admin'), adminController.getSyncQueueStats);
router.get('/payment-events', authenticate, authorizeRoles('admin'), adminController.getPaymentEvents);

export default router;