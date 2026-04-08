import pool from '../config/db.js'

export const createPreparationHeader = async (data, client = pool) => {
    const { title, test_type, section, summary, status, created_by } = data
    const result = await client.query(
        `INSERT INTO lessons (title , test_type, section, summary, status, created_by)
        VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`, [title, test_type, section, summary, status, created_by]
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
    const { test_type, section, status } = filters
    let query = `SELECT * FROM lessons WHERE 1=1`
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
    query += `ORDER BY created_at DESC`
    const result = await pool.query(query,values)
    return result.rows
}

export const getFullPrepByID = async (id) => {
    const prepResult = await pool.query(`SELECT * FROM lessons WHERE id = $1`, [id])
    if (prepResult.rows.length === 0) return null
    const partsResult = await pool.query(`SELECT * FROM lesson_parts WHERE lesson_id = $1 ORDER BY order_number ASC`,
        [id]
    )
    return {
        ...prepResult.rows[0],
        parts : partsResult.rows
    }
}

export const deletePreparation = async (id,client = pool) => {
    const result = await client.query(`DELETE FROM lessons WHERE id = $1 RETURNING *`, [id])
    return result.rows[0]
}