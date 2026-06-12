import pool from './src/config/db.js';

async function check() {
  try {
    const res = await pool.query("SELECT id, display_id, title, exam_type, is_published FROM tests");
    console.log("TESTS IN DB :", res.rows);
    process.exit(0);
  } catch (err) {
    console.error("ERROR:", err);
    process.exit(1);
  }
}

check();
