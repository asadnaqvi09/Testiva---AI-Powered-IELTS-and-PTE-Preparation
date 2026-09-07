import { createCheckoutSchema } from "../validator/payment.validator.js";
import {
  stripe,
  isStripeConfigured,
  getPlan,
} from "../services/stripe.service.js";
import {
  findPaymentBySessionId,
  insertPaymentEvent,
} from "../models/payment.model.js";
import { updateUserPaymentUnlock, findUserById } from "../../M1_Identity/user.model.js";
import { resolveUnlockedExam, resolveSubscription } from "../../../utils/helpers.js";

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
          price_label: "Rs 399",
          unlocked_exam: "IELTS",
          subscription: "basic",
        },
        {
          plan: "basic_pte",
          label: "Basic PTE",
          price_label: "Rs 399",
          unlocked_exam: "PTE",
          subscription: "basic",
        },
        {
          plan: "premium",
          label: "Premium (IELTS + PTE)",
          price_label: "Rs 699",
          unlocked_exam: "BOTH",
          subscription: "premium",
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

    const plan = getPlan(value.plan);
    if (!plan) {
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

    const priceId = process.env[plan.envPriceKey];
    const lineItems = priceId
      ? [{ price: priceId, quantity: 1 }]
      : [
          {
            price_data: {
              currency: plan.currency,
              product_data: { name: `Testiva ${plan.label}` },
              unit_amount: plan.fallbackUnitAmount,
            },
            quantity: 1,
          },
        ];

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      customer_email: user.email,
      client_reference_id: user.id,
      line_items: lineItems,
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        user_id: user.id,
        plan: value.plan,
        unlocked_exam: plan.unlocked_exam,
        subscription: plan.subscription,
      },
    });

    return res.status(200).json({
      success: true,
      data: {
        sessionId: session.id,
        url: session.url,
        plan: value.plan,
      },
    });
  } catch (error) {
    console.error("createCheckoutSession:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to create checkout session",
    });
  }
};

export const applyCheckoutSessionEntitlement = async (session) => {
  const sessionId = session.id;
  const existing = await findPaymentBySessionId(sessionId);
  if (existing) {
    const user = await findUserById(existing.user_id);
    return { alreadyProcessed: true, user };
  }

  const userId =
    session.metadata?.user_id || session.client_reference_id || null;
  const planKey = session.metadata?.plan;
  const plan = getPlan(planKey);
  const subscription =
    session.metadata?.subscription || plan?.subscription || "basic";
  const unlockedExam =
    session.metadata?.unlocked_exam || plan?.unlocked_exam || null;

  if (!userId || !unlockedExam) {
    throw new Error("Checkout session missing user_id or unlocked_exam metadata");
  }

  const updated = await updateUserPaymentUnlock(userId, {
    subscription,
    unlocked_exam: unlockedExam,
  });

  await insertPaymentEvent({
    userId,
    stripeSessionId: sessionId,
    stripePaymentIntent:
      typeof session.payment_intent === "string"
        ? session.payment_intent
        : session.payment_intent?.id,
    plan: planKey || "unknown",
    unlockedExam,
    subscription,
    amountTotal: session.amount_total,
    currency: session.currency,
    rawPayload: session,
  });

  return { alreadyProcessed: false, user: updated };
};

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

    return res.json({
      success: true,
      alreadyProcessed: result.alreadyProcessed,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription: resolveSubscription(user),
        preference: user.preference,
        unlocked_exam: resolveUnlockedExam(user),
      },
    });
  } catch (error) {
    console.error("confirmCheckoutSession:", error);
    return res.status(500).json({ success: false, message: error.message || "Confirm failed" });
  }
};

export const getMyEntitlements = async (req, res) => {
  try {
    const user = await findUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    return res.json({
      success: true,
      data: {
        subscription: resolveSubscription(user),
        preference: user.preference,
        unlocked_exam: resolveUnlockedExam(user),
        app_base: appBaseUrl(),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Failed" });
  }
};
