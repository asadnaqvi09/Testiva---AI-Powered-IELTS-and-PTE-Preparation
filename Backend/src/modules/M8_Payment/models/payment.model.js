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

/** L6 — paginated ledger (admin + student invoices) */
export const listPaymentEventsPaginated = async ({
  limit = 20,
  offset = 0,
  userId = null,
  plan = null,
}) => {
  const conditions = [];
  const params = [];
  let i = 1;
  if (userId) {
    conditions.push(`pe.user_id = $${i++}::uuid`);
    params.push(userId);
  }
  if (plan) {
    conditions.push(`pe.plan = $${i++}`);
    params.push(plan);
  }
  const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const limitIdx = i;
  const offsetIdx = i + 1;
  const dataParams = [...params, limit, offset];
  const [rows, countRow] = await Promise.all([
    pool.query(
      `SELECT pe.id, pe.user_id, pe.stripe_session_id, pe.stripe_payment_intent,
              pe.plan, pe.unlocked_exam, pe.subscription, pe.amount_total,
              pe.currency, pe.status, pe.created_at,
              u.full_name, u.email
       FROM payment_events pe
       LEFT JOIN users u ON u.id = pe.user_id
       ${where}
       ORDER BY pe.created_at DESC
       LIMIT $${limitIdx} OFFSET $${offsetIdx}`,
      dataParams,
    ),
    pool.query(
      `SELECT COUNT(*)::INT AS total FROM payment_events pe ${where}`,
      params,
    ),
  ]);
  return { items: rows.rows, total: countRow.rows[0]?.total || 0 };
};

export const listPaymentEventsForUser = async (userId, { limit = 20, offset = 0 } = {}) =>
  listPaymentEventsPaginated({ limit, offset, userId });
