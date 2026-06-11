import pool from './src/config/db.js';

const email = `TestUser_${Date.now()}@example.com`;

async function test() {
  console.log("Registering...", email);
  const res1 = await fetch("http://localhost:5000/api/v1/auth/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      full_name: "Test User",
      email,
      password: "Password123!",
      confirm_password: "Password123!"
    })
  });
  const data1 = await res1.json();
  console.log("Register response:", data1);

  // Note: TestUser gets lowercased to testuser in temp_users! Let's get the OTP from logs
  // Wait, I can't easily read logs, I will get the hashed OTP from DB directly just to check if it's there
  const { rows } = await pool.query("SELECT * FROM temp_users WHERE email=$1", [email.toLowerCase()]);
  console.log("DB lookup for lowercased email:", rows.length > 0 ? "Found" : "Not Found");

  // Since I can't read the plain OTP, I'll just check if VerifyOtp returns 400 Invalid OTP (meaning it found the user but wrong OTP) instead of No User Found
  const res2 = await fetch("http://localhost:5000/api/v1/auth/verify-otp", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email, // using mixed case!
      otp: "9999",
      type: "register"
    })
  });
  const data2 = await res2.json();
  console.log("Verify OTP response (with mixed case email and wrong OTP):", data2);
  
  process.exit(0);
}
test();
