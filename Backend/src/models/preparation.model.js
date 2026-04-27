import pool from '../config/db.js'

export const createPreparationHeader = async (data, client = pool) => {
    const { title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, created_by } = data
    const result = await client.query(
        `INSERT INTO lessons (title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, created_by)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`, [title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, created_by]
    )
    return result.rows[0]
}

export const createPreparationPart = async (data, client = pool) => {
    const { lesson_id, part_title, part_content, order_number } = data
    const result = await client.query(
        `INSERT INTO lesson_parts (lesson_id, part_title, part_content, order_number)
        VALUES ($1,$2,$3,$4) RETURNING *`, [lesson_id, part_title, part_content, order_number]
    )
    return result.rows[0]
}

export const getAllPreparations = async (filters = {}) => {
    const { test_type, section, status, min_subscription, target_band } = filters
    let query = `SELECT id, title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, created_at 
        FROM lessons 
        WHERE 1=1`
    const values = [];
    if (test_type) {
        values.push(test_type);
        query += `AND test_type = $${values.length}`
    }
    if (section) {
        values.push(section);
        query += `AND section = $${values.length}`
    }
    if (status) {
        values.push(status);
        query += `AND status = $${values.length}`
    }
    if (min_subscription) {
        values.push(min_subscription);
        query += ` AND min_subscription = $${values.length}`;
    }
    if (target_band) {
        values.push(target_band);
        query += ` AND target_band <= $${values.length}`;
    }
    query += `ORDER BY created_at DESC`
    const result = await pool.query(query,values)
    return result.rows
}

export const getLessonsBySubscription = async (subscription, test_type = null, section = null) => {
    const allowedSubscriptions = ['free'];
    if (subscription === 'basic' || subscription === 'premium') allowedSubscriptions.push('basic');
    if (subscription === 'premium') allowedSubscriptions.push('premium');
    let query = `
        SELECT id, title, test_type, section, summary, target_band, estimated_minutes, tags, created_at 
        FROM lessons 
        WHERE status = 'published' 
        AND min_subscription = ANY($1)`;
    const values = [allowedSubscriptions];
    if (test_type) {
        values.push(test_type);
        query += ` AND test_type = $${values.length}`;
    }
    if (section) {
        values.push(section);
        query += ` AND section = $${values.length}`;
    }
    query += ` ORDER BY target_band ASC, created_at DESC`;
    const result = await pool.query(query, values);
    return result.rows;
};

export const getFullPrepByID = async (id) => {
    const prepResult = await pool.query(`SELECT id, title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, created_by, created_at 
    FROM lessons WHERE id = $1`, [id])
    if (prepResult.rows.length === 0) return null
    const partsResult = await pool.query(`SELECT id, lesson_id, part_title, part_content, order_number, created_at
    FROM lesson_parts WHERE lesson_id = $1 ORDER BY order_number ASC`,[id]
    )
    return {
        ...prepResult.rows[0],
        parts : partsResult.rows
    }
}

export const updatePreparation = async (id,data,client= pool) => {
    const fields = [];
    const values = [];
    let idx = 1;
    if (data.title !== undefined) { fields.push(`title = $${idx++}`); values.push(data.title); }
    if (data.test_type !== undefined) { fields.push(`test_type = $${idx++}`); values.push(data.test_type); }
    if (data.section !== undefined) { fields.push(`section = $${idx++}`); values.push(data.section); }
    if (data.summary !== undefined) { fields.push(`summary = $${idx++}`); values.push(data.summary); }
    if (data.status !== undefined) { fields.push(`status = $${idx++}`); values.push(data.status); }
    if (data.min_subscription !== undefined) { fields.push(`min_subscription = $${idx++}`); values.push(data.min_subscription); }
    if (data.target_band !== undefined) { fields.push(`target_band = $${idx++}`); values.push(data.target_band); }
    if (data.estimated_minutes !== undefined) { fields.push(`estimated_minutes = $${idx++}`); values.push(data.estimated_minutes); }
    if (data.tags !== undefined) { fields.push(`tags = $${idx++}`); values.push(JSON.stringify(data.tags)); }
    if (fields.length === 0) throw new Error("No fields to update")
    values.push(id);
    const query = `
        UPDATE lessons 
        SET ${fields.join(', ')}, updated_at = NOW() 
        WHERE id = $${idx} 
        RETURNING id, title, test_type, section, summary, status, min_subscription, target_band, estimated_minutes, tags, updated_at`
    ;
    const result = await client.query(query,values);
    return result.rows[0];
}

export const deletePreparation = async (id,client = pool) => {
    const result = await client.query(`DELETE FROM lessons WHERE id = $1 RETURNING id,title`, [id])
    return result.rows[0]
}

export const deletePreparationParts = async (lesson_id, client = pool) => {
    await client.query(`DELETE FROM lesson_parts WHERE lesson_id = $1`, [lesson_id]);
    
}