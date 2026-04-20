import pool from "../../config/db.js";
import { createGoogleUser, createUser, findUserByEmail } from "../../models/user.model.js";
import bcrypt from "bcrypt";
import * as authValidator from "../../validators/auth.validator.js";
import { generateGuestToken, generateToken } from "../../utils/jwt.js";
import { verifyGoogleToken } from "./google.service.js";
import { sendOtpEmail } from "../../utils/email.service.js";

export const resolveSubscription = (user) => {
  return user.role === "admin" ? "premium" : user.subscription;
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
    const otp = Math.floor(1000 + Math.random() * 9000);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    const password_hash = await bcrypt.hash(password, 10);
    await pool.query(
      `INSERT INTO temp_users (email, full_name, password_hash, otp_code, expires_at)
       VALUES ($1, $2, $3, $4, $5)`,
      [email, full_name, password_hash, otp, expiresAt]
    );
    await sendOtpEmail(email, otp);
    return res.status(200).json({
      success: true,
      message: "OTP sent to email",
      email
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "User registration failed"
    });
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
      return res.status(400).json({ success: false, message: "Invalid Credentials" });
    }
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: "Invalid Credentials" });
    }
    const subscription = resolveSubscription(user);
    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription
    });
    await pool.query("UPDATE users SET last_login_at=NOW() WHERE id=$1", [user.id]);
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
  } catch (error) {
    return res.status(500).json({ success: false, message: "Login failed" });
  }
};

export const verifyOTP = async (req,res) => {
  try {
    const {email,otp} = req.body;
    if (!otp) return res.status(400).json({ success: false, message: "OTP Required"});
    const result = await pool.query(
      'SELECT * FROM temp_users WHERE email = $1 AND otp_code = $2',
      [email,otp]
    );
    const tempUser = result.rows[0];
    if(!tempUser) return res.status(400).json({success: false, message: "Invalid OTP"});
    if (new Date(tempUser.expires_at) < new Date()) {
      await pool.query(`DELETE FROM temp_users WHERE email=$1`, [email]);
      return res.status(400).json({ success: false, message: "OTP expired" });
    }
    const user = await createUser({
      full_name: tempUser.full_name,
      email: tempUser.email,
      password_hash: tempUser.password_hash,
      auth_provider
    });
    await pool.query(`DELETE FROM temp_users WHERE email=$1`, [email]);
    const subscription = resolveSubscription(user);
    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription
    });
    return res.status(201).json({
      success: true,
      message: "Account verified successfully",
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "OTP verification failed"
    });
  }
}

export const resendOTP = async (req,res) => {
  try {
    const {email} = req.body;
    if(!email) return res.status(400).json({ success : false , message: "Email Required"});
    const existing = await pool.query(`SELECT * FROM temp_users WHERE email=$1`, [email]);
    if(!existing.rows[0]) return res.status(400).json({ success : false, message: "No OTP avaiable for this email"});
    const otp = Math.floor(1000 + Math.random() * 9000);
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    await pool.query(
      `UPDATE temp_users 
       SET otp_code=$1, expires_at=$2 
       WHERE email=$3`,
      [otp, expiresAt, email]
    );
    await sendOtpEmail(email, otp);
    return res.status(200).json({
      success: true,
      message: "OTP resent successfully"
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Failed to resend OTP"
    });
  }
}

export const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ success: false, message: "Token Required" });
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
    } else if (user.auth_provider !== "google") {
      return res.status(409).json({
        success: false,
        message: "Account exists with password. Please login with password."
      });
    }
    const subscription = resolveSubscription(user);
    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription
    });
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
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Google Authentication Failed"
    });
  }
};

export const guestAccess = async (req, res) => {
  try {
    const token = generateGuestToken();
    return res.status(200).json({
      success: true,
      token,
      role: "guest"
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Guest Access Failed"
    });
  }
};

export const logoutUser = async (req, res) => {
  try {
    const userId = req.user?.id || "Unknown";
    console.log(`User ${userId} logged out`);
    return res.status(200).json({
      success: true,
      message: "User logged out successfully"
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Logout failed"
    });
  }
};