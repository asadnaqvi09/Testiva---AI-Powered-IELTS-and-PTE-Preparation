import pool from './src/config/db.js';

async function test() {
  const { rows } = await pool.query("SELECT * FROM temp_users");
  console.log(rows);
  process.exit(0);
}
test();
