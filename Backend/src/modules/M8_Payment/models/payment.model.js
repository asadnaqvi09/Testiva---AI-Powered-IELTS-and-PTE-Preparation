import pool from "../../../config/db.js";

export const findPaymentBySessionId = async (sessionId) => {
  const { rows } = await pool.query(
    `SELECT * FROM payment_events WHERE stripe_session_id = $1 LIMIT 1`,
    [sessionId]
  );
  return rows[0] || null;
};

export const insertPaymentEvent = async ({
  userId,
  stripeSessionId,
  stripePaymentIntent,
  plan,
  unlockedExam,
  subscription,
  amountTotal,
  currency,
  rawPayload,
}) => {
  const { rows } = await pool.query(
    `INSERT INTO payment_events (
      user_id, stripe_session_id, stripe_payment_intent, plan,
      unlocked_exam, subscription, amount_total, currency, status, raw_payload
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'completed',$9::jsonb)
    ON CONFLICT (stripe_session_id) DO NOTHING
    RETURNING *`,
    [
      userId,
      stripeSessionId,
      stripePaymentIntent || null,
      plan,
      unlockedExam,
      subscription,
      amountTotal ?? null,
      currency || null,
      JSON.stringify(rawPayload || {}),
    ]
  );
  return rows[0] || null;
};
