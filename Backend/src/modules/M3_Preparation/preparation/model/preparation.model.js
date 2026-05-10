import pool from '../../../../config/db.js';

export const createPreparationHeader = async (data, client = pool) => {
    const { title, test_type, section, summary, status } = data;
    const result = await client.query(
        `INSERT INTO preparations (title, test_type, section, summary, status)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, title, test_type, section, summary, status, created_at, updated_at`,
        [title, test_type, section, summary ?? null, status]
    );
    return result.rows[0];
};

export const createPrepPart = async (data, client = pool) => {
    const { prep_id, part_title, part_content, order_index } = data;
    const result = await client.query(
        `INSERT INTO prep_parts (prep_id, part_title, part_content, order_index)
         VALUES ($1, $2, $3, $4)
         RETURNING id, prep_id, part_title, part_content, order_index`,
        [prep_id, part_title, part_content, order_index]
    );
    return result.rows[0];
};

export const createPrepMedia = async (data, client = pool) => {
    const { prep_id, file_url, file_name, file_size, file_type } = data;
    const result = await client.query(
        `INSERT INTO prep_media (prep_id, file_url, file_name, file_size, file_type)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, prep_id, file_url, file_name, file_size, file_type`,
        [prep_id, file_url, file_name, file_size ?? null, file_type ?? 'application/pdf']
    );
    return result.rows[0];
};

export const getFullPrepByID = async (id) => {
    const [prepResult, partsResult, mediaResult] = await Promise.all([
        pool.query(
            `SELECT id, title, test_type, section, summary, status, created_at, updated_at 
             FROM preparations WHERE id = $1`,
            [id]
        ),
        pool.query(
            `SELECT id, part_title, part_content, order_index
             FROM prep_parts WHERE prep_id = $1 ORDER BY order_index ASC`,
            [id]
        ),
        pool.query(
            `SELECT id, file_url, file_name, file_size, file_type
             FROM prep_media WHERE prep_id = $1`,
            [id]
        )
    ]);

    if (prepResult.rows.length === 0) return null;

    return {
        ...prepResult.rows[0],
        parts: partsResult.rows,
        media: mediaResult.rows
    };
};

export const getAllPreparations = async (test_type, section, search) => {
    let query = `SELECT id, title, test_type, section, summary, status, created_at, updated_at 
                 FROM preparations WHERE 1=1`;
    const params = [];
    if (test_type) {
        params.push(test_type);
        query += ` AND test_type = $${params.length}`;
    }
    if (section) {
        params.push(section);
        query += ` AND section = $${params.length}`;
    }
    if (search) {
        params.push(`%${search}%`);
        query += ` AND title ILIKE $${params.length}`;
    }
    query += ` ORDER BY created_at DESC`;
    const result = await pool.query(query, params);
    return result.rows;
};

export const updatePreparationHeader = async (id, data, client = pool) => {
    const query = `
        UPDATE preparations 
        SET 
            title = COALESCE($1, title),
            test_type = COALESCE($2, test_type),
            section = COALESCE($3, section),
            summary = COALESCE($4, summary),
            status = COALESCE($5, status),
            updated_at = NOW()
        WHERE id = $6
        RETURNING id, title, test_type, section, summary, status, created_at, updated_at
    `;

    const values = [
        data.title ?? null,
        data.test_type ?? null,
        data.section ?? null,
        data.summary ?? null,
        data.status ?? null,
        id
    ];

    const result = await client.query(query, values);
    return result.rows[0];
};

export const deletePreparation = async (id, client = pool) => {
    const result = await client.query(
        `DELETE FROM preparations WHERE id = $1 RETURNING id`,
        [id]
    );
    return result.rows[0];
};

export const deletePrepParts = async (prep_id, client = pool) => {
    await client.query(`DELETE FROM prep_parts WHERE prep_id = $1`, [prep_id]);
};

export const deletePrepMedia = async (prep_id, client = pool) => {
    await client.query(`DELETE FROM prep_media WHERE prep_id = $1`, [prep_id]);
};