import pool from './src/config/db.js';
import { listMobilePublished } from './src/modules/M2_Test/models/test.model.js';

async function test() {
  try {
    const userRes = await pool.query("SELECT id, email, role, subscription FROM users LIMIT 5");
    console.log("USERS:", userRes.rows);
    
    if (userRes.rows.length > 0) {
      const firstUser = userRes.rows[0];
      console.log(`Testing listMobilePublished for user: ${firstUser.email} (${firstUser.id})`);
      const tests = await listMobilePublished(firstUser.id, ["IELTS"]);
      console.log("MOBILE TESTS:", tests);
    } else {
      console.log("No users in database.");
    }
    process.exit(0);
  } catch (err) {
    console.error("ERROR:", err);
    process.exit(1);
  }
}

test();
