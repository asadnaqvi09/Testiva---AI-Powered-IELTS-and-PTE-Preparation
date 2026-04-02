import pool from "../../config/db.js";
import { createGoogleUser, createUser, findUserByEmail } from "../../models/user.model.js";
import bcrypt from "bcrypt";
import * as authValidator from "../../validators/auth.validator.js";
import { generateGuestToken, generateToken } from "../../utils/jwt.js";
import { verifyGoogleToken } from './auth.service.js';

export const registerUser = async (req, res) => {
  try {
    const { value, error } = authValidator.registerSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    const { full_name, email, password } = value;
    const existingUser = await findUserByEmail(email);
    if (existingUser) return res.status(409).json({ success: false, message: "Email already registered" });
    const password_hash = await bcrypt.hash(password, 10);
    const user = await createUser({ full_name, email, password_hash });
    res.status(201).json({ success: true, message: "User registered successfully", user });
  } catch (error) {
    res.status(500).json({ success: false, message: "User registration failed" });
  }
};

export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ success: false, message: "Fields required" });
    const user = await findUserByEmail(email);
    if (!user || !user.password_hash) return res.status(400).json({ success: false, message: "Invalid Credentials" });
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) return res.status(400).json({ success: false, message: "Invalid Credentials" });
    const token = generateToken({ id: user.id, role: user.role, subscription: user.subscription });
    await pool.query("UPDATE users SET last_login_at=NOW() WHERE id=$1", [user.id]);
    res.status(200).json({
      success: true,
      token,
      user: { id: user.id, full_name: user.full_name, email: user.email, role: user.role, subscription: user.subscription }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Login failed" });
  }
};

export const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ success: false, message: "Token Required" });
    const googleUser = await verifyGoogleToken(idToken);
    let user = await findUserByEmail(googleUser.email);
    if (!user) {
      user = await createGoogleUser({
        email: googleUser.email,
        full_name: googleUser.full_name,
        avatar_url: googleUser.avatar_url
      });
    }
    const token = generateToken({ id: user.id, role: user.role, subscription: user.subscription });
    res.status(200).json({ success: true, token, user });
  } catch (error) {
    res.status(500).json({ success: false, message: "Google Authentication Failed" });
  }
};

export const guestAccess = async (req, res) => {
  try {
    const token = generateGuestToken();
    res.status(200).json({ success: true, token, role: "guest" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Guest Access Failed" });
  }
};

export const logoutUser = async (req, res) => {
  try {
    const userId = req.user?.id || "Unknown";
    console.log(`User ${userId} logged out`);
    res.status(200).json({
      success: true,
      message: "User logged out successfully"
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Logout failed"
    });
  }
};