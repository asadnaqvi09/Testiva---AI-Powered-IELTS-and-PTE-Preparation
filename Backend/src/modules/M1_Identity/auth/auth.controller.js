import pool from "../../../config/db.js";
import {
  createGoogleUser,
  createUser,
  findUserByEmail,
  findRefreshToken,
  deleteRefreshToken,
  deleteAllUserTokens,
  findUserById
} from "../user.model.js";
import * as authValidator from "./auth.validator.js";
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken
} from "../../../utils/jwt.js";
import { verifyGoogleToken } from "./google.service.js";
import { sendOtpEmail } from "../../../email_templates/email.service.js";
import { hashPassword, generateOTP, resolveSubscription, hashOTP } from "../../../utils/helpers.js";
import { redisClient } from "../../../config/redis.js";
import bcrypt from "bcrypt";
import jwt from 'jsonwebtoken';

const hashOtpValue = async (otp) => {
  return await hashOTP(String(otp));
};

export const registerUser = async (req, res) => {
  try {
    const { value, error } = authValidator.registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, message: error.details[0].message });
    }
    const { full_name, email, password } = value;
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ success: false, message: "Email already registered" });
    }
    const otp = generateOTP();
    const otp_hash = await hashOtpValue(otp);
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
    await sendOtpEmail({email, otp, type:"register"});
    return res.status(200).json({ success: true, message: "OTP sent", email });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Registration failed" });
  }
};

export const loginUser = async (req, res) => {
  try {
    const { value, error } = authValidator.loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, message: error.details[0].message });
    }
    const { email, password } = value;
    const user = await findUserByEmail(email);
    if (!user || !user.password_hash) {
      return res.status(400).json({ success: false, message: "Invalid credentials" });
    }
    if (!user.is_email_verified) {
      return res.status(403).json({ success: false, message: "Email not verified" });
    }
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(400).json({ success: false, message: "Invalid credentials" });
    }
    const payload = {
      id: user.id,
      role: user.role,
      subscription: resolveSubscription(user),
      tokenVersion: user.token_version
    };
    const accessToken = generateAccessToken(payload);
    const refreshToken = generateRefreshToken(user.id);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await pool.query(
      `INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES ($1,$2,$3)`,
      [user.id, refreshToken, expiresAt]
    );
    await pool.query(`UPDATE users SET last_login_at = NOW() WHERE id = $1`, [user.id]);
    return res.status(200).json({
      success: true,
      accessToken,
      refreshToken,
      expiresIn: "15m",
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription: resolveSubscription(user)
      }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Login failed" });
  }
};

export const refreshAccessToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        message: "Refresh token required"
      });
    }
    let decoded;
    try {
      decoded = verifyRefreshToken(refreshToken);
    } catch {
      return res.status(401).json({
        success: false,
        message: "Invalid refresh token"
      });
    }
    const stored = await findRefreshToken(refreshToken);
    if (!stored) {
      return res.status(401).json({
        success: false,
        message: "Refresh token not found"
      });
    }
    if (new Date(stored.expires_at) < new Date()) {
      await deleteRefreshToken(refreshToken);
      return res.status(401).json({
        success: false,
        message: "Refresh token expired"
      });
    }
    const user = await findUserById(decoded.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User not found"
      });
    }
    if (decoded.tokenVersion !== user.token_version) {
      await deleteRefreshToken(refreshToken);
      return res.status(401).json({
        success: false,
        message: "Token invalidated"
      });
    }
    const accessToken = generateAccessToken({
      id: user.id,
      role: user.role,
      subscription: resolveSubscription(user),
      tokenVersion: user.token_version
    });
    const newRefreshToken = generateRefreshToken(user.id);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await pool.query(
      `DELETE FROM refresh_tokens WHERE user_id = $1`,
      [user.id]
    );
    await pool.query(
      `INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES ($1,$2,$3)`,
      [user.id, newRefreshToken, expiresAt]
    );
    return res.status(200).json({
      success: true,
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: "15m"
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: "Token refresh failed"
    });
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
    const otp_hash = await hashOtpValue(otp);
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
    await sendOtpEmail({email, otp,type:"reset"});
    return res.status(200).json({ success: true, message: "OTP sent" });
  } catch {
    return res.status(500).json({ success: false, message: "Request failed" });
  }
};

export const verifyOTP = async (req, res) => {
  const client = await pool.connect();
  try {
    const { email, otp, type } = req.body;
    if (!email || !otp || !type) {
      return res.status(400).json({ success: false, message: "All fields required" });
    }
    await client.query('BEGIN');
    const { rows } = await client.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type=$2 FOR UPDATE`,
      [email, type]
    );
    const tempUser = rows[0];
    if (!tempUser) {
      await client.query('ROLLBACK');
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }
    if (tempUser.attempts >= 5) {
      await client.query(`DELETE FROM temp_users WHERE email=$1 AND type=$2`, [email, type]);
      await client.query('COMMIT');
      return res.status(400).json({ success: false, message: "Too many attempts" });
    }
    const match = await bcrypt.compare(String(otp), tempUser.otp_code);
    if (!match) {
      await client.query(
        `UPDATE temp_users SET attempts = attempts + 1 WHERE email=$1 AND type=$2`,
        [email, type]
      );
      await client.query('COMMIT');
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }
    if (new Date(tempUser.expires_at) < new Date()) {
      await client.query(`DELETE FROM temp_users WHERE email=$1 AND type=$2`, [email, type]);
      await client.query('COMMIT');
      return res.status(400).json({ success: false, message: "OTP expired" });
    }
    if (type === "register") {
      const { rows: userRows } = await client.query(
        `INSERT INTO users (full_name, email, password_hash, auth_provider, is_email_verified)
         VALUES ($1,$2,$3,'email',true)
         RETURNING id, full_name, email, role, subscription, auth_provider, created_at`,
        [tempUser.full_name, tempUser.email, tempUser.password_hash]
      );
      const user = userRows[0];
      await client.query(`DELETE FROM temp_users WHERE email=$1 AND type='register'`, [email]);
      await client.query('COMMIT');
      const token = generateAccessToken({
        id: user.id,
        role: user.role,
        subscription: resolveSubscription(user)
      });
      return res.status(201).json({ success: true, message: "Account verified", token, user });
    }
    if (type === "reset") {
      await client.query(
        `UPDATE temp_users SET is_verified=true WHERE email=$1 AND type='reset'`,
        [email]
      );
      await client.query('COMMIT');
      return res.status(200).json({ success: true, message: "OTP verified" });
    }
    await client.query('ROLLBACK');
    return res.status(400).json({ success: false, message: "Invalid type" });
  } catch (error) {
    await client.query('ROLLBACK');
    return res.status(500).json({ success: false, message: "Verification failed" });
  } finally {
    client.release();
  }
};

export const resetPassword = async (req, res) => {
  const client = await pool.connect();
  try {
    const { email, new_password, confirm_password } = req.body;
    if (!email || !new_password || !confirm_password) {
      return res.status(400).json({ success: false, message: "All fields required" });
    }
    if (new_password !== confirm_password) {
      return res.status(400).json({ success: false, message: "Passwords do not match" });
    }
    await client.query('BEGIN');
    const { rows } = await client.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type='reset' AND is_verified=true FOR UPDATE`,
      [email]
    );
    if (!rows[0]) {
      await client.query('ROLLBACK');
      return res.status(400).json({ success: false, message: "OTP not verified" });
    }
    const password_hash = await hashPassword(new_password);
    await client.query(
      `UPDATE users SET password_hash=$1, token_version = token_version + 1, updated_at=NOW() WHERE email=$2`,
      [password_hash, email]
    );
    await client.query(`DELETE FROM temp_users WHERE email=$1 AND type='reset'`, [email]);
    await client.query(`DELETE FROM refresh_tokens WHERE user_id=(SELECT id FROM users WHERE email=$1)`, [email]);
    await client.query('COMMIT');
    return res.status(200).json({ success: true, message: "Password reset successful" });
  } catch (error) {
    await client.query('ROLLBACK');
    return res.status(500).json({ success: false, message: "Reset failed" });
  } finally {
    client.release();
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
      return res.status(400).json({ success: false, message: "Account already verified. Please login." });
    }
    const otp = generateOTP();
    const otp_hash = await hashOtpValue(otp);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    await pool.query(
      `UPDATE temp_users SET otp_code=$1, expires_at=$2, attempts=0 WHERE email=$3 AND type=$4`,
      [otp_hash, expiresAt, email, type]
    );
    await sendOtpEmail({email, otp,type:"reset"});
    return res.status(200).json({ success: true, message: "OTP resent" });
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
    } else if (user.auth_provider !== 'google') {
      return res.status(409).json({
        success: false,
        message: "Account exists with password. Please login with password."
      });
    }
    const token = generateAccessToken({
      id: user.id,
      role: user.role,
      subscription: resolveSubscription(user),
      tokenVersion: user.token_version
    });
    return res.status(200).json({ success: true, token, user });
  } catch {
    return res.status(500).json({ success: false, message: "Google auth failed" });
  }
};

export const logoutUser = async (req, res) => {
  try {
    const refreshToken = req.body.refreshToken;
    const accessToken = req.token;
    if (!refreshToken) {
      return res.status(400).json({ success: false, message: "Refresh token required" });
    }
    await deleteRefreshToken(refreshToken);
    try {
      const decoded = verifyRefreshToken(refreshToken);
      const ttl = decoded.exp - Math.floor(Date.now() / 1000);
      if (ttl > 0) {
        await redisClient.set(`bl:${refreshToken}`, "1", "EX", ttl);
      }
    } catch (error) {
      console.error("Error occurred while verifying refresh token:", error);
    }
    if (accessToken) {
      try {
        const decoded = jwt.verify(accessToken, process.env.JWT_SECRET);
        const ttl = decoded.exp - Math.floor(Date.now() / 1000);
        if (ttl > 0) {
          await redisClient.set(`bl:${accessToken}`, "1", "EX", ttl);
        }
      } catch {}
    }
    return res.status(200).json({ success: true, message: "Logged out" });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Logout failed" });
  }
};

export const logoutAllUserDevices = async (req, res) => {
  try {
    const userId = req.user.id;
    await deleteAllUserTokens(userId);
    await pool.query(
      `UPDATE users SET token_version = token_version + 1, updated_at=NOW() WHERE id=$1`,
      [userId]
    );
    return res.status(200).json({ success: true, message: "Logged out from all devices" });
  } catch {
    return res.status(500).json({ success: false, message: "Force logout failed" });
  }
};