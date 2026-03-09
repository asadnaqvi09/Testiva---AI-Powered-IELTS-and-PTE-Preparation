import pkg from "pg";
import dotenv from "dotenv";

dotenv.config();

const { Pool } = pkg;

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Test database connection
const testDBConnection = async () => {
  try {
    const client = await pool.connect();
    const res = await client.query("SELECT NOW()");
    console.log("PostgreSQL Connected at:", res.rows[0].now);
    client.release();
  } catch (error) {
    console.error("Database connection error:", error);
  }
};

testDBConnection();

export default pool;