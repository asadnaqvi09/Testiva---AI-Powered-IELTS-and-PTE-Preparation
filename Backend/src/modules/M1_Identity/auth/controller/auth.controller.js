import pool from "../../../../config/db.js";
import {
  createGoogleUser,
  findUserByEmail,
  findRefreshToken,
  deleteRefreshToken,
  deleteAllUserTokens,
  findUserById,
  updateUserPreference,
} from "../../user.model.js";
import * as authValidator from "../validator/auth.validator.js";
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} from "../../../../utils/jwt.js";
import { handleAdminNewUserNotification } from "../../../M9_Notification/engine/notification.engine.js";
import { verifyGoogleToken } from "../services/google.service.js";
import { sendOtpEmail } from "../../../../email_templates/email.service.js";
import {
  hashPassword,
  generateOTP,
  resolveSubscription,
  hashOTP,
} from "../../../../utils/helpers.js";
import bcrypt from "bcrypt";

const hashOtpValue = async (otp) => hashOTP(String(otp));
const buildToken = (user) => ({
  id: user.id,
  role: user.role,
  subscription: resolveSubscription(user),
  tokenVersion: user.token_version,
  preference: user.preference, 
});

export const registerUser = async (req, res) => {
  try {
    const { error, value } = authValidator.registerSchema.validate(req.body);
    if (error)
      return res
        .status(400)
        .json({ success: false, message: error.details[0].message });
    const { full_name, email, password } = value;
    const exists = await findUserByEmail(email);
    if (exists)
      return res
        .status(409)
        .json({ success: false, message: "Email already registered" });
    const otp = generateOTP();
    const otp_hash = await hashOtpValue(otp);
    const password_hash = await hashPassword(password);
    await pool.query(
      `INSERT INTO temp_users (email, full_name, password_hash, otp_code, expires_at, type, attempts, is_verified)
       VALUES ($1,$2,$3,$4,NOW() + INTERVAL '15 minutes','register',0,false)
       ON CONFLICT (email, type)
       DO UPDATE SET full_name=$2, password_hash=$3, otp_code=$4, expires_at=NOW() + INTERVAL '15 minutes', attempts=0, is_verified=false`,
      [email, full_name, password_hash, otp_hash],
    );
    await sendOtpEmail({ email, otp, type: "register" });
    return res.json({ success: true, message: "OTP sent", email });
  } catch (error) {
    console.log("Error In Register Controller : ", error.message);
    return res
      .status(500)
      .json({ success: false, message: error.message || "Registration failed" });
  }
};

export const loginUser = async (req, res) => {
  try {
    const { error, value } = authValidator.loginSchema.validate(req.body);
    if (error)
      return res
        .status(400)
        .json({ success: false, message: error.details[0].message });
    const { email, password } = value;
    const user = await findUserByEmail(email);
    if (!user?.password_hash)
      return res
        .status(400)
        .json({ success: false, message: "Invalid credentials" });
    if (!user.is_email_verified)
      return res
        .status(403)
        .json({ success: false, message: "Email not verified" });
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match)
      return res
        .status(400)
        .json({ success: false, message: "Invalid credentials" });
    const accessToken = generateAccessToken(buildToken(user));
    const refreshToken = generateRefreshToken(user.id);
    await pool.query(
      `INSERT INTO refresh_tokens (user_id, token, expires_at)
       VALUES ($1,$2,NOW() + INTERVAL '7 days')`,
      [user.id, refreshToken],
    );
    await pool.query(`UPDATE users SET last_login_at=NOW() WHERE id=$1`, [
      user.id,
    ]);
    return res.json({
      success: true,
      accessToken,
      refreshToken,
      expiresIn: "15m",
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription: resolveSubscription(user),
        preference: user.preference,
      },
    });
  } catch (error) {
    console.log("Error In Login Controller : ", error.message);
    return res.status(500).json({ success: false, message: "Login failed" });
  }
};

export const verifyOTP = async (req, res) => {
  const client = await pool.connect();

  try {
    const { error, value } = authValidator.otpSchema.validate(req.body);

    if (error) {
      return res
        .status(400)
        .json({ success: false, message: error.details[0].message });
    }
<<<<<<< Updated upstream

    const { email, otp, type } = value;

=======
    const { email, otp, type, preference } = value;
>>>>>>> Stashed changes
    await client.query("BEGIN");

    const { rows } = await client.query(
      `SELECT *, (expires_at < NOW()) as is_expired FROM temp_users WHERE email=$1 AND type=$2 FOR UPDATE`,
      [email, type],
    );

    const temp = rows[0];

    if (!temp) {
      await client.query("ROLLBACK");
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }

    if (temp.attempts >= 5) {
      await client.query(`DELETE FROM temp_users WHERE email=$1 AND type=$2`, [
        email,
        type,
      ]);

      await client.query("COMMIT");

      return res
        .status(400)
        .json({ success: false, message: "Too many attempts" });
    }

    const match = await bcrypt.compare(String(otp), temp.otp_code);

    if (!match) {
      await client.query(
        `UPDATE temp_users SET attempts = attempts + 1 WHERE email=$1 AND type=$2`,
        [email, type],
      );

      await client.query("COMMIT");

      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }
<<<<<<< Updated upstream

    if (new Date(temp.expires_at) < new Date()) {
=======
    if (temp.is_expired) {
>>>>>>> Stashed changes
      await client.query(`DELETE FROM temp_users WHERE email=$1 AND type=$2`, [
        email,
        type,
      ]);

      await client.query("COMMIT");

      return res.status(400).json({ success: false, message: "OTP expired" });
    }

    if (type === "register") {
      const { rows: userRows } = await client.query(
        `INSERT INTO users (full_name,email,password_hash,auth_provider,is_email_verified,subscription,preference)
         VALUES ($1,$2,$3,'email',true,'free',$4)
         RETURNING *`,
        [temp.full_name, temp.email, temp.password_hash, preference || null],
      );

      const user = userRows[0];

      await client.query(
        `DELETE FROM temp_users WHERE email=$1 AND type='register'`,
        [email],
      );

      await client.query("COMMIT");

      try {
        await handleAdminNewUserNotification(req.io, user);
      } catch (e) {
        console.error(e);
      }
<<<<<<< Updated upstream

      return res.status(201).json({
        success: true,
        message: "Account verified",
        user,
=======
      await client.query(
        `DELETE FROM temp_users WHERE email=$1 AND type='register'`,
        [email],
      );

      const accessToken = generateAccessToken(buildToken(user));
      const refreshToken = generateRefreshToken(user.id);
      await client.query(
        `INSERT INTO refresh_tokens (user_id, token, expires_at)
         VALUES ($1,$2,NOW() + INTERVAL '7 days')`,
        [user.id, refreshToken],
      );

      await client.query("COMMIT");
      return res.status(201).json({
        success: true,
        message: "Account verified",
        accessToken,
        refreshToken,
        expiresIn: "15m",
        user: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          role: user.role,
          subscription: resolveSubscription(user),
          preference: user.preference,
        },
>>>>>>> Stashed changes
      });
    }

    if (type === "reset") {
      await client.query(
        `UPDATE temp_users SET is_verified=true WHERE email=$1 AND type='reset'`,
        [email],
      );

      await client.query("COMMIT");

      return res.json({ success: true, message: "OTP verified" });
    }

    await client.query("ROLLBACK");
  } catch (err) {
    console.error("DEBUG verifyOTP error:", err);

    await client.query("ROLLBACK");

    return res
      .status(500)
      .json({ success: false, message: "Verification failed" });
  } finally {
    client.release();
  }
};

export const setUserPreference = async (req, res) => {
  try {
    const loggedInUser = req.user;
    const { preference, targetUserId } = req.body;
    if (!preference || !["IELTS", "PTE"].includes(preference)) {
      return res.status(400).json({
        success: false,
        message: "Invalid preference track validation failed.",
      });
    }
    const isAdminMode = loggedInUser && (loggedInUser.role === 'admin');
    const userIdToUpdate = (isAdminMode && targetUserId) ? targetUserId : loggedInUser.id;
    const userCheck = await findUserById(userIdToUpdate);
    if (!userCheck) {
      return res.status(400).json({
        success: false,
        message: "Target user record not found in system pool.",
      });
    }
    if (!isAdminMode && userCheck.preference !== null) {
      return res.status(403).json({
        success: false,
        message: "Preference already locked. Please submit a change request to Admin from profile settings.",
        requiresAdminApproval: true
      });
    }
    const user = await updateUserPreference(userIdToUpdate, preference);
    const updatedToken = generateAccessToken(buildToken(user));

    return res.status(200).json({
      success: true,
      message: isAdminMode 
        ? `User preference forcefully updated to ${preference} via Admin Override.` 
        : "Preference locked successfully.",
      accessToken: updatedToken,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        preference: user.preference,
      }
    });
  } catch (error) {
    console.error("Error in setUserPreference Controller:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to set preference infrastructure mapping.",
    });
  }
};

export const refreshAccessToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken)
      return res
        .status(401)
        .json({ success: false, message: "Refresh token required" });
    const decoded = verifyRefreshToken(refreshToken);
    const stored = await findRefreshToken(refreshToken);
    if (!stored)
      return res.status(401).json({ success: false, message: "Invalid token" });
    if (stored.is_expired) {
      await deleteRefreshToken(refreshToken);
      return res.status(401).json({ success: false, message: "Expired token" });
    }
    const user = await findUserById(decoded.userId);
    if (!user)
      return res
        .status(401)
        .json({ success: false, message: "User not found" });
    if (decoded.tokenVersion !== user.token_version) {
      await deleteRefreshToken(refreshToken);
      return res
        .status(401)
        .json({ success: false, message: "Token invalidated" });
    }
    const accessToken = generateAccessToken(buildToken(user));
    const newRefreshToken = generateRefreshToken(user.id);
    await pool.query(
      `INSERT INTO refresh_tokens (user_id, token, expires_at)
       VALUES ($1,$2,NOW() + INTERVAL '7 days')`,
      [
        user.id,
        newRefreshToken,
      ],
    );
    return res.json({
      success: true,
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: "15m",
    });
  } catch {
    return res.status(500).json({ success: false, message: "Refresh failed" });
  }
};

export const forgotPassword = async (req, res) => {
  try {
    const { error, value } = authValidator.forgotPasswordSchema.validate(req.body);
    if (error) {
      return res
        .status(400)
        .json({ success: false, message: error.details[0].message });
    }
    const { email } = value;
    const user = await findUserByEmail(email);
    if (!user)
      return res
        .status(400)
        .json({ success: false, message: "User not found" });
    const otp = generateOTP();
    const otp_hash = await hashOtpValue(otp);
    await pool.query(
      `INSERT INTO temp_users (email, otp_code, expires_at, type, attempts, is_verified)
       VALUES ($1,$2,NOW() + INTERVAL '15 minutes','reset',0,false)
       ON CONFLICT (email, type)
       DO UPDATE SET otp_code=$2, expires_at=NOW() + INTERVAL '15 minutes', attempts=0, is_verified=false`,
      [email, otp_hash],
    );
    await sendOtpEmail({ email, otp, type: "reset" });
    return res.json({ success: true, message: "OTP sent" });
  } catch (error) {
    console.log("Error In Forgot Password Controller : ", error.message);
    return res.status(500).json({ success: false, message: error.message || "Request failed" });
  }
};

export const resetPassword = async (req, res) => {
  const client = await pool.connect();
  try {
    const { error, value } = authValidator.resetPasswordSchema.validate(req.body);
    if (error) {
      return res
        .status(400)
        .json({ success: false, message: error.details[0].message });
    }
    const { email, new_password } = value;
    await client.query("BEGIN");
    const { rows } = await client.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type='reset' AND is_verified=true FOR UPDATE`,
      [email],
    );
    if (!rows[0]) {
      await client.query("ROLLBACK");
      return res
        .status(400)
        .json({ success: false, message: "OTP not verified" });
    }
    const password_hash = await hashPassword(new_password);
    await client.query(
      `UPDATE users 
       SET password_hash=$1, token_version = token_version + 1, updated_at=NOW() 
       WHERE email=$2`,
      [password_hash, email],
    );
    await client.query(
      `DELETE FROM temp_users WHERE email=$1 AND type='reset'`,
      [email],
    );
    await client.query(
      `DELETE FROM refresh_tokens 
       WHERE user_id = (SELECT id FROM users WHERE email=$1)`,
      [email],
    );
    await client.query("COMMIT");
    return res.status(200).json({
      success: true,
      message: "Password reset successful",
    });
  } catch (error) {
    await client.query("ROLLBACK");
    return res.status(500).json({
      success: false,
      message: "Reset failed",
    });
  } finally {
    client.release();
  }
};

export const resendOTP = async (req, res) => {
  try {
    const { error, value } = authValidator.resendOtpSchema.validate(req.body);
    if (error) {
      return res
        .status(400)
        .json({ success: false, message: error.details[0].message });
    }
    const { email, type } = value;
    const { rows } = await pool.query(
      `SELECT * FROM temp_users WHERE email=$1 AND type=$2`,
      [email, type],
    );
    if (!rows[0])
      return res.status(400).json({ success: false, message: "Not found" });
    const otp = generateOTP();
    const otp_hash = await hashOtpValue(otp);
    await pool.query(
      `UPDATE temp_users SET otp_code=$1, expires_at=NOW() + INTERVAL '15 minutes', attempts=0 WHERE email=$2 AND type=$3`,
      [otp_hash, email, type],
    );
    await sendOtpEmail({ email, otp, type });
    return res.json({ success: true, message: "OTP resent" });
  } catch (error) {
    console.log("Error In Resend OTP Controller : ", error.message);
    return res.status(500).json({ success: false, message: error.message || "Failed" });
  }
};

export const googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken)
      return res
        .status(400)
        .json({ success: false, message: "Token required" });
    const googleUser = await verifyGoogleToken(idToken);
    if (googleUser.email_verified !== true) {
      return res.status(400).json({
        success: false,
        message: "Google OAuth rejected: This email address is unverified at the provider level."
      });
    }
    let user = await findUserByEmail(googleUser.email);
    if (!user) {
      user = await createGoogleUser({
        email: googleUser.email,
        full_name: googleUser.full_name,
        avatar_url: googleUser.avatar_url,
        subscription: "free",
        preference: null,
      });
      try {
        await handleAdminNewUserNotification(req.io, user);
      } catch (e) {
        console.error(e);
      }
    }
    const accessToken = generateAccessToken(buildToken(user));
    const refreshToken = generateRefreshToken(user.id);
    await pool.query(
      `INSERT INTO refresh_tokens (user_id, token, expires_at)
       VALUES ($1,$2,NOW() + INTERVAL '7 days')`,
      [user.id, refreshToken],
    );
    return res.json({
      success: true,
      accessToken,
      refreshToken,
      expiresIn: "15m",
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
        subscription: resolveSubscription(user),
        preference: user.preference,
        avatar_url: user.avatar_url,
      },
    });
  } catch (error) {
    console.error("Error in googleAuth:", error);
    return res
      .status(500)
      .json({ success: false, message: "Google auth failed" });
  }
};

export const logoutUser = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    await deleteRefreshToken(refreshToken);
    return res.json({ success: true, message: "Logged out" });
  } catch {
    return res.status(500).json({ success: false, message: "Logout failed" });
  }
};

export const logoutAllUserDevices = async (req, res) => {
  try {
    const userId = req.user.id;
    await deleteAllUserTokens(userId);
    await pool.query(
      `UPDATE users SET token_version = token_version + 1 WHERE id=$1`,
      [userId],
    );
    return res.json({ success: true, message: "Logged out all devices" });
  } catch {
    return res.status(500).json({ success: false, message: "Failed" });
  }
};