import express from 'express';
import { authenticate } from '../../../middleware/auth.middleware.js';
import * as aiController from './ai.controller.js';
const router = express.Router();

router.post('/evaluate',authenticate,aiController.evaluateSubmission);

export default router;