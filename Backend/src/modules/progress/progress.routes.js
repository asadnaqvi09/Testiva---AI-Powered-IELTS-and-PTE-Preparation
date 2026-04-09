import express from 'express';
import * as progressController from './progress.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js'

const router = express.Router();

router.post('/submit-test', authenticate, progressController.submitTest);
router.post('/my-stats', authenticate, progressController.getMyStats);

export default router;