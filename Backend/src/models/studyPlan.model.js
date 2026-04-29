import pool from '../config/db.js';

export const createStudyPlan = async (data) => {
    const { user_id, title, target_band, start_date, end_date } = data;
    const result = await pool.query(
        `INSERT INTO study_plans (user_id, title, target_band, start_date, end_date)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, user_id, title, target_band, start_date, end_date, status, created_at`,
        [user_id, title, target_band, start_date, end_date]
    );
    return result.rows[0];
};

export const addStudyPlanItems = async (planId, items, client = pool) => {
    if (items.length === 0) return [];
    const placeholders = items.map((_, i) => `($${i * 6 + 1}, $${i * 6 + 2}, $${i * 6 + 3}, $${i * 6 + 4}, $${i * 6 + 5}, $${i * 6 + 6})`).join(', ');
    const flatValues = items.flatMap(item => [planId, item.day_number, item.item_type, item.item_id, item.title, item.estimated_minutes]);
    const result = await client.query(
        `INSERT INTO study_plan_items (plan_id, day_number, item_type, item_id, title, estimated_minutes)
         VALUES ${placeholders}
         RETURNING id, plan_id, day_number, item_type, title, estimated_minutes, is_completed`,
        flatValues
    );
    return result.rows;
};

export const getActiveStudyPlan = async (userId) => {
    const result = await pool.query(
        `SELECT id, user_id, title, target_band, start_date, end_date, status, created_at
         FROM study_plans
         WHERE user_id = $1 AND status = 'active'
         ORDER BY created_at DESC
         LIMIT 1`,
        [userId]
    );
    return result.rows[0];
};

export const getTodayPlanItems = async (userId) => {
    const result = await pool.query(
        `SELECT spi.id, spi.plan_id, spi.day_number, spi.item_type, spi.item_id, spi.title, spi.estimated_minutes, spi.is_completed
         FROM study_plan_items spi
         JOIN study_plans sp ON spi.plan_id = sp.id
         WHERE sp.user_id = $1
         AND sp.status = 'active'
         AND spi.day_number = (CURRENT_DATE - sp.start_date + 1)
         ORDER BY spi.item_type`,
        [userId]
    );
    return result.rows;
};

export const markItemComplete = async (itemId) => {
    const result = await pool.query(
        `UPDATE study_plan_items
         SET is_completed = true, completed_at = NOW()
         WHERE id = $1
         RETURNING id, is_completed, completed_at`,
        [itemId]
    );
    return result.rows[0];
};

export const getPlanProgress = async (planId) => {
    const result = await pool.query(
        `SELECT 
            COUNT(*) as total_items,
            COUNT(*) FILTER (WHERE is_completed = true) as completed_items,
            ROUND(COUNT(*) FILTER (WHERE is_completed = true) * 100.0 / COUNT(*), 2) as progress_percent
         FROM study_plan_items
         WHERE plan_id = $1`,
        [planId]
    );
    return result.rows[0];
};

export const completeStudyPlan = async (planId) => {
    const result = await pool.query(
        `UPDATE study_plans SET status = 'completed', updated_at = NOW() WHERE id = $1 RETURNING id, status`,
        [planId]
    );
    return result.rows[0];
};