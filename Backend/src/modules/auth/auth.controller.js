import pool from "../../config/db.js";
import {
  createGoogleUser,
  createUser,
  findUserByEmail
} from "../../models/user.model.js";

import * as authValidator from "../../validators/auth.validator.js";
import { generateGuestToken, generateToken } from "../../utils/jwt.js";
import { verifyGoogleToken } from "./google.service.js";
import { sendOtpEmail } from "../../config/nodemailer.js";
import { hashPassword, generateOTP, resolveSubscription, hashOTP } from "../../utils/helpers.js";
import bcrypt from "bcrypt";

const buildOtpHash = async (otp) => {
  return await hashOTP(String(otp));
};

export const registerUser = async (req, res) => {
  try {
    const { value, error } = authValidator.registerSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });

    const { full_name, email, password, confirm_password } = value;

    if (password !== confirm_password) {
      return res.status(400).json({ success: false, message: "Passwords do not match" });
    }

    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ success: false, message: "Email already registered" });
    }

    const otp = generateOTP();
    const otp_hash = await buildOtpHash(otp);
    const password_hash = await hashPassword(password);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await pool.query(
      `INSERT INTO temp_users (email, full_name, password_hash, otp_code, expires_at, type, attempts, is_verified)
       VALUES ($1,$2,$3,$4,$5,'register',0,false)
       ON CONFLICT (email, type)
       DO UPDATE SET
         full_name = EXCLUDED.full_name,
         password_hash = EXCLUDED.password_hash,
         otp_code = EXCLUDED.otp_code,
         expires_at = EXCLUDED.expires_at,
         attempts = 0,
         is_verified = false`,
      [email, full_name, password_hash, otp_hash, expiresAt]
    );

    await sendOtpEmail(email, otp);

    return res.status(200).json({
      success: true,
      message: "OTP sent",
      email
    });
  } catch (error) {
    console.error("Registration error:", error);
    console.log("Registration Error : ", error);
    return res.status(500).json({ success: false, message: "Registration failed" });
  }
};

export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: "Fields required" });
    }

    const user = await findUserByEmail(email);

    if (!user || !user.password_hash) {
      return res.status(400).json({ success: false, message: "Invalid credentials" });
    }

    if (!user.is_email_verified) {
      return res.status(403).json({ success: false, message: "Verify email first" });
    }

    const match = await bcrypt.compare(password, user.password_hash);

    if (!match) {
      return res.status(400).json({ success: false, message: "Invalid credentials" });
    }

    const subscription = resolveSubscription(user);

    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription
    });

    await pool.query(`UPDATE users SET last_login_at=NOW() WHERE id=$1`, [user.id]);

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription
      }
    });
  } catch {
    return res.status(500).json({ success: false, message: "Login failed" });
  }
};

export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ success: false, message: "Email required" });
    }

    const user = await findUserByEmail(email);

    if (!user) {
      return res.status(400).json({ success: false, message: "User not found" });
    }

    const otp = generateOTP();
    const otp_hash = await buildOtpHash(otp);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await pool.query(
      `INSERT INTO temp_users (email, otp_code, expires_at, type, attempts, is_verified)
       VALUES ($1,$2,$3,'reset',0,false)
       ON CONFLICT (email, type)
       DO UPDATE SET
         otp_code = EXCLUDED.otp_code,
         expires_at = EXCLUDED.expires_at,
         attempts = 0,
         is_verified = false`,
      [email, otp_hash, expiresAt]
    );

    await sendOtpEmail(email, otp);

    return res.status(200).json({
      success: true,
      message: "OTP sent"
    });
  } catch {
    return res.status(500).json({ success: false, message: "Request failed" });
  }
};

export const verifyOTP = async (req, res) => {
  try {
    const { email, otp, type } = req.body;

    if (!email || !otp || !type) {
      return res.status(400).json({ success: false, message: "All fields required" });
    }

    const { rows } = await pool.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type=$2`,
      [email, type]
    );

    const tempUser = rows[0];

    if (!tempUser) {
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }

    if (tempUser.attempts >= 5) {
      await pool.query(`DELETE FROM temp_users WHERE email=$1 AND type=$2`, [email, type]);
      return res.status(400).json({ success: false, message: "Too many attempts" });
    }

    const match = await bcrypt.compare(String(otp), tempUser.otp_code);

    if (!match) {
      await pool.query(
        `UPDATE temp_users SET attempts = attempts + 1 WHERE email=$1 AND type=$2`,
        [email, type]
      );
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }

    if (new Date(tempUser.expires_at) < new Date()) {
      await pool.query(`DELETE FROM temp_users WHERE email=$1 AND type=$2`, [email, type]);
      return res.status(400).json({ success: false, message: "OTP expired" });
    }

    if (type === "register") {
      const user = await createUser({
        full_name: tempUser.full_name,
        email: tempUser.email,
        password_hash: tempUser.password_hash,
        auth_provider: "email",
        is_email_verified: true
      });

      await pool.query(`DELETE FROM temp_users WHERE email=$1 AND type='register'`, [email]);

      const token = generateToken({
        id: user.id,
        role: user.role,
        subscription: resolveSubscription(user)
      });

      return res.status(201).json({
        success: true,
        message: "Account verified",
        token,
        user
      });
    }

    if (type === "reset") {
      await pool.query(
        `UPDATE temp_users SET is_verified=true WHERE email=$1 AND type='reset'`,
        [email]
      );

      return res.status(200).json({
        success: true,
        message: "OTP verified"
      });
    }

    return res.status(400).json({ success: false, message: "Invalid type" });
  } catch {
    return res.status(500).json({ success: false, message: "Verification failed" });
  }
};

export const resetPassword = async (req, res) => {
  try {
    const { email, new_password, confirm_password } = req.body;

    if (!email || !new_password || !confirm_password) {
      return res.status(400).json({ success: false, message: "All fields required" });
    }

    if (new_password !== confirm_password) {
      return res.status(400).json({ success: false, message: "Passwords do not match" });
    }

    const { rows } = await pool.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type='reset' AND is_verified=true`,
      [email]
    );

    if (!rows[0]) {
      return res.status(400).json({ success: false, message: "OTP not verified" });
    }

    const password_hash = await hashPassword(new_password);

    await pool.query(
      `UPDATE users SET password_hash=$1, updated_at=NOW() WHERE email=$2`,
      [password_hash, email]
    );

    await pool.query(`DELETE FROM temp_users WHERE email=$1 AND type='reset'`, [email]);

    return res.status(200).json({
      success: true,
      message: "Password reset successful"
    });
  } catch {
    return res.status(500).json({ success: false, message: "Reset failed" });
  }
};

export const resendOTP = async (req, res) => {
  try {
    const { email, type } = req.body;

    if (!email || !type) {
      return res.status(400).json({ success: false, message: "Email and type required" });
    }

    const { rows } = await pool.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type=$2`,
      [email, type]
    );

    if (!rows[0]) {
      return res.status(400).json({ success: false, message: "No OTP found" });
    }

    const otp = generateOTP();
    const otp_hash = await buildOtpHash(otp);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await pool.query(
      `UPDATE temp_users SET otp_code=$1, expires_at=$2, attempts=0 WHERE email=$3 AND type=$4`,
      [otp_hash, expiresAt, email, type]
    );

    await sendOtpEmail(email, otp);

    return res.status(200).json({
      success: true,
      message: "OTP resent"
    });
  } catch {
    return res.status(500).json({ success: false, message: "Resend failed" });
  }
};

export const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ success: false, message: "Token required" });
    }

    const googleUser = await verifyGoogleToken(idToken);

    let user = await findUserByEmail(googleUser.email);

    if (!user) {
      user = await createGoogleUser({
        email: googleUser.email,
        full_name: googleUser.full_name,
        avatar_url: googleUser.avatar_url,
        subscription: "free"
      });
    }

    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription: resolveSubscription(user)
    });

    return res.status(200).json({
      success: true,
      token,
      user
    });
  } catch {
    return res.status(500).json({ success: false, message: "Google auth failed" });
  }
};

export const guestAccess = async (req, res) => {
  try {
    const token = generateGuestToken();
    return res.status(200).json({ success: true, token, role: "guest" });
  } catch {
    return res.status(500).json({ success: false, message: "Guest failed" });
  }
};

export const logoutUser = async (req, res) => {
  try {
    return res.status(200).json({ success: true, message: "Logged out" });
  } catch {
    return res.status(500).json({ success: false, message: "Logout failed" });
  }
};