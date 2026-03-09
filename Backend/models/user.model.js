import pool from "../config/db";

export const createUser = async (userData) => {
    const { full_name, email, password } = userData;
    try {
        const result = await pool.query(
            'INSERT INTO users (full_name, email, password_hash) VALUES ($1, $2, $3) RETURNING *',
            [full_name, email, password]
        );
        return result.rows[0];
    } catch (error) {
        console.error('Error creating user:', error);
        throw error;
    }
}