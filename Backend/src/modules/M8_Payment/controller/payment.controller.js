import { createCheckoutSchema } from "../validator/payment.validator.js";
import {
  stripe,
  isStripeConfigured,
  getPlan,
} from "../services/stripe.service.js";
import { findUserById } from "../../M1_Identity/user.model.js";
import { resolveUnlockedExam, resolveSubscription } from "../../../utils/helpers.js";
import {
  createStripeCheckoutSession,
  applyCheckoutEntitlement,
} from "../services/payment.service.js";
import { listPaymentEventsForUser } from "../models/payment.model.js";

const appBaseUrl = () =>
  process.env.APP_PUBLIC_URL ||
  process.env.CLIENT_URL ||
  "http://localhost:5173";

const flutterReturnBase = () =>
  process.env.FLUTTER_PAYMENT_RETURN_URL || "testiva://payment";

export const listPlans = async (_req, res) => {
  try {
    return res.json({
      success: true,
      data: [
        {
          plan: "basic_ielts",
          label: "Basic IELTS",
          price: 399,
          price_label: "Rs 399",
          currency: "PKR",
          unlocked_exam: "IELTS",
          subscription: "basic",
          desc: "Single-exam unlock via Stripe (IELTS)",
        },
        {
          plan: "basic_pte",
          label: "Basic PTE",
          price: 399,
          price_label: "Rs 399",
          currency: "PKR",
          unlocked_exam: "PTE",
          subscription: "basic",
          desc: "Single-exam unlock via Stripe (PTE)",
        },
        {
          plan: "premium",
          label: "Premium (IELTS + PTE)",
          price: 699,
          price_label: "Rs 699",
          currency: "PKR",
          unlocked_exam: "BOTH",
          subscription: "premium",
          desc: "Full unlock for both exams",
        },
      ],
      stripe_configured: isStripeConfigured(),
    });
  } catch (error) {
    console.error("listPlans:", error);
    return res.status(500).json({ success: false, message: "Failed to list plans" });
  }
};

export const createCheckoutSession = async (req, res) => {
  try {
    if (!isStripeConfigured()) {
      return res.status(503).json({
        success: false,
        message: "Stripe is not configured. Set STRIPE_SECRET_KEY in Backend .env",
      });
    }

    const { error, value } = createCheckoutSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, message: error.details[0].message });
    }

    if (!getPlan(value.plan)) {
      return res.status(400).json({ success: false, message: "Invalid plan" });
    }

    const user = await findUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const successUrl =
      value.success_url ||
      `${flutterReturnBase()}-success?session_id={CHECKOUT_SESSION_ID}`;
    const cancelUrl =
      value.cancel_url || `${flutterReturnBase()}-cancel`;

    // This is a comment: checkout creation via payment.service
    const session = await createStripeCheckoutSession({
      user,
      planKey: value.plan,
      successUrl,
      cancelUrl,
    });

    return res.status(200).json({
      success: true,
      data: {
        session_id: session.id,
        sessionId: session.id,
        checkout_url: session.url,
        url: session.url,
        plan: value.plan,
      },
    });
  } catch (error) {
    console.error("createCheckoutSession:", error);
    const raw = error.message || "Failed to create checkout session";
    const missingKey = /STRIPE|api[_ ]?key|Invalid API Key/i.test(raw)
      ? "Stripe key missing or invalid in Backend .env"
      : raw;
    return res.status(500).json({
      success: false,
      message: missingKey,
    });
  }
};

export const applyCheckoutSessionEntitlement = (session) =>
  applyCheckoutEntitlement(session);

export const stripeWebhook = async (req, res) => {
  try {
    if (!isStripeConfigured()) {
      return res.status(503).send("Stripe not configured");
    }

    const sig = req.headers["stripe-signature"];
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    let event;

    if (webhookSecret && sig) {
      event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
    } else if (process.env.NODE_ENV !== "production") {
      event = typeof req.body === "string" || Buffer.isBuffer(req.body)
        ? JSON.parse(req.body.toString())
        : req.body;
      console.warn("[Stripe] Webhook signature skipped (dev mode / no STRIPE_WEBHOOK_SECRET)");
    } else {
      return res.status(400).send("Webhook secret required");
    }

    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      if (session.payment_status === "paid" || session.status === "complete") {
        await applyCheckoutSessionEntitlement(session);
      }
    }

    return res.json({ received: true });
  } catch (error) {
    console.error("stripeWebhook:", error.message);
    return res.status(400).send(`Webhook Error: ${error.message}`);
  }
};

export const confirmCheckoutSession = async (req, res) => {
  try {
    if (!isStripeConfigured()) {
      return res.status(503).json({ success: false, message: "Stripe not configured" });
    }
    const sessionId = req.query.session_id || req.body?.session_id;
    if (!sessionId) {
      return res.status(400).json({ success: false, message: "session_id required" });
    }

    const session = await stripe.checkout.sessions.retrieve(sessionId);
    if (session.metadata?.user_id && session.metadata.user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: "Session does not belong to user" });
    }

    if (session.payment_status !== "paid" && session.status !== "complete") {
      return res.status(400).json({
        success: false,
        message: "Payment not completed yet",
        payment_status: session.payment_status,
      });
    }

    const result = await applyCheckoutSessionEntitlement(session);
    const user = result.user || (await findUserById(req.user.id));

    // clean and optimized code — unlock payload for Flutter PremiumModal
    const unlockedUser = {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      role: user.role,
      subscription: resolveSubscription(user),
      preference: user.preference,
      unlocked_exam: resolveUnlockedExam(user),
    };

    return res.json({
      success: true,
      alreadyProcessed: result.alreadyProcessed,
      user: unlockedUser,
      data: { user: unlockedUser },
    });
  } catch (error) {
    console.error("confirmCheckoutSession:", error);
    const raw = error.message || "Confirm failed";
    const missingKey = /STRIPE|api[_ ]?key|Invalid API Key/i.test(raw)
      ? "Stripe key missing or invalid in Backend .env"
      : raw;
    return res.status(500).json({ success: false, message: missingKey });
  }
};

export const getMyEntitlements = async (req, res) => {
  try {
    const user = await findUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    const subscription = resolveSubscription(user);
    const unlocked = resolveUnlockedExam(user);
    return res.json({
      success: true,
      data: {
        plan: subscription,
        subscription,
        preference: user.preference,
        unlocked_exam: unlocked,
        status: subscription === "free" ? "inactive" : "active",
        renews_at: null,
        app_base: appBaseUrl(),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed" });
  }
};

// L6 — student invoice / payment history from payment_events
export const listMyInvoices = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(50, Math.max(1, parseInt(req.query.limit, 10) || 20));
    const offset = (page - 1) * limit;
    const { items, total } = await listPaymentEventsForUser(req.user.id, {
      limit,
      offset,
    });
    const invoices = items.map((row) => ({
      id: row.id,
      plan: row.plan,
      subscription: row.subscription,
      unlocked_exam: row.unlocked_exam,
      amount_total: row.amount_total,
      currency: row.currency,
      status: row.status,
      stripe_session_id: row.stripe_session_id,
      created_at: row.created_at,
    }));
    return res.json({
      success: true,
      data: {
        items: invoices,
        meta: {
          page,
          limit,
          total,
          total_pages: Math.ceil(total / limit) || 1,
        },
      },
    });
  } catch (error) {
    console.error("listMyInvoices:", error);
    return res.status(500).json({ success: false, message: "Failed to load invoices" });
  }
};
