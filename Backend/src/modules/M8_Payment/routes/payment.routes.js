import express from "express";
import { authenticate } from "../../../middleware/auth.middleware.js";
import * as paymentController from "../controller/payment.controller.js";

const router = express.Router();

router.get("/plans", authenticate, paymentController.listPlans);
router.post("/checkout", authenticate, paymentController.createCheckoutSession);
router.get("/confirm", authenticate, paymentController.confirmCheckoutSession);
router.post("/confirm", authenticate, paymentController.confirmCheckoutSession);
router.get("/me", authenticate, paymentController.getMyEntitlements);

export default router;
