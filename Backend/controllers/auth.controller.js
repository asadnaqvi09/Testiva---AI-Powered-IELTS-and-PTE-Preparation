import pool from "../config/db.js";
import { createGoogleUser, createUser, findUserByEmail } from "../models/user.model.js";
import bcrypt from "bcrypt";
import * as authValidator from "../validators/auth.validator.js";
import { generateGuestToken, generateToken } from "../utils/jwt.js";
import { verifyGoogleToken } from '../services/auth.service.js';

export const registerUser = async (req, res) => {
  try {
    const { value, error } = authValidator.registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message,
      });
    }
    const { full_name, email, password } = value;
    if (!full_name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "All fields are required",
      });
    }
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "Email already registered",
      });
    }
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);
    const user = await createUser({
      full_name,
      email,
      password_hash,
    });
    res.status(201).json({
      success: true,
      message: "User registered successfully",
      user,
    });
  } catch (error) {
    console.error("Error in Register Controller:", error);
    res.status(500).json({
      success: false,
      message: "User registration failed",
    });
  }
};

export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please Fill All Required Fields",
      });
    }
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(400).json({
        success: false,
        message: "Invalid Credentials",
      });
    }
    const comparePassword = await bcrypt.compare(password, user.password_hash);
    if (!comparePassword) {
      return res.status(400).json({
        success: false,
        message: "Invalid Credentials",
      });
    }
    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription: user.subscription,
    });
    await pool.query("UPDATE users SET last_login_at=NOW() WHERE id=$1", [
      user.id,
    ]);
    res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription: user.subscription,
      },
    });
  } catch (error) {
    console.error("Error in Login Controller", error);
    res.status(500).json({
      success: false,
      message: "User login failed",
    });
  }
};

export const guestAccess = async (req, res) => {
  try {
    const token = generateGuestToken();
    res.status(200).json({
      success: true,
      message: "Guest access granted",
      token,
      role: "guest",
    });
  } catch (error) {
    console.error("Error in Guest Controller", error);
    res.status(500).json({
      success: false,
      message: "Guest Access Failed"
    })
  }
};

export const logoutUser = async (req, res) => {
  try {
    const userId = req.user.id;
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

export const googleAuth = async (req,res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: "Google Token Required"
      })
    };
    const googleUser = await verifyGoogleToken(idToken);
    const user = await findUserByEmail(googleUser.email);
    if (!user) {
      user = await createGoogleUser({
        email: googleUser.email,
        full_name: googleUser.full_name,
        avatar_url: googleUser.avatar_url
      });
    };
    const token = generateToken({
      id: user.id,
      role: user.role,
      subscription: user.subscription
    });
    res.status(200).json({
      success: true,
      message: "Google Login Successful",
      token,
      user
    });
  } catch (error) {
    console.error("Google Auth Error: " , error);
    res.status(500).json({
      success: false,
      message: "Google Authentication Failed"
    });
  }
}