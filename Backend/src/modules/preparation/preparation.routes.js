import express from 'express';
import * as prepController from './preparation.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';
import { authorizeRoles } from '../../middleware/role.middleware.js';

const router = express.Router();

router.get(
    '/preparations', 
    authenticate, 
    prepController.getPrepLessons
);

router.get(
    '/preparations/:id', 
    authenticate, 
    prepController.getPrepDetails
);

router.post(
    '/preparations', 
    authenticate, 
    authorizeRoles('admin'), 
    prepController.createPrepLesson
);

router.delete(
    '/preparations/:id', 
    authenticate, 
    authorizeRoles('admin'), 
    prepController.deletePrepLesson
);

export default router;