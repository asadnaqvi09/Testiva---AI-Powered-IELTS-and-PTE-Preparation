import Stripe from "stripe";

const stripeSecret = process.env.STRIPE_SECRET_KEY;

export const stripe = stripeSecret
  ? new Stripe(stripeSecret)
  : null;

export const isStripeConfigured = () => Boolean(stripe);

/** planKey -> { subscription, unlocked_exam, label, envPriceId } */
export const PLAN_CATALOG = {
  basic_ielts: {
    label: "Basic IELTS",
    subscription: "basic",
    unlocked_exam: "IELTS",
    envPriceKey: "STRIPE_PRICE_BASIC_IELTS",
    fallbackUnitAmount: 39900,
    currency: "pkr",
  },
  basic_pte: {
    label: "Basic PTE",
    subscription: "basic",
    unlocked_exam: "PTE",
    envPriceKey: "STRIPE_PRICE_BASIC_PTE",
    fallbackUnitAmount: 39900,
    currency: "pkr",
  },
  premium: {
    label: "Premium (IELTS + PTE)",
    subscription: "premium",
    unlocked_exam: "BOTH",
    envPriceKey: "STRIPE_PRICE_PREMIUM",
    fallbackUnitAmount: 69900,
    currency: "pkr",
  },
};

export const getPlan = (planKey) => PLAN_CATALOG[planKey] || null;
