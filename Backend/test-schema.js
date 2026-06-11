import pool from './src/config/db.js';

async function checkSchema() {
  const { rows } = await pool.query("SELECT column_name, character_maximum_length FROM information_schema.columns WHERE table_name = 'temp_users'");
  console.log(rows);
  process.exit(0);
}
checkSchema();
