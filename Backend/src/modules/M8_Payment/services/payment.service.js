import {
  stripe,
  isStripeConfigured,
  getPlan,
} from "./stripe.service.js";
import {
  findPaymentBySessionId,
  insertPaymentEvent,
} from "../models/payment.model.js";
import {
  updateUserPaymentUnlock,
  findUserById,
} from "../../M1_Identity/user.model.js";

// This is a comment: payment business logic extracted from controller

export async function buildCheckoutLineItems(plan) {
  const priceId = process.env[plan.envPriceKey];
  if (priceId) return [{ price: priceId, quantity: 1 }];
  return [
    {
      price_data: {
        currency: plan.currency,
        product_data: { name: `Testiva ${plan.label}` },
        unit_amount: plan.fallbackUnitAmount,
      },
      quantity: 1,
    },
  ];
}

export async function createStripeCheckoutSession({
  user,
  planKey,
  successUrl,
  cancelUrl,
}) {
  const plan = getPlan(planKey);
  if (!plan) throw new Error("Invalid plan");
  if (!isStripeConfigured()) throw new Error("Stripe is not configured");

  const lineItems = await buildCheckoutLineItems(plan);
  return stripe.checkout.sessions.create({
    mode: "payment",
    customer_email: user.email,
    client_reference_id: user.id,
    line_items: lineItems,
    success_url: successUrl,
    cancel_url: cancelUrl,
    metadata: {
      user_id: user.id,
      plan: planKey,
      unlocked_exam: plan.unlocked_exam,
      subscription: plan.subscription,
    },
  });
}

export async function applyCheckoutEntitlement(session) {
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
}
