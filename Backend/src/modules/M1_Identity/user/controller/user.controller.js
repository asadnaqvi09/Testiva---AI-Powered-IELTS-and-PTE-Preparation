import pool from "../../../../config/db.js";
import { findUserById, updateUserProfile, updateUserPassword, uploadUserAvatar, updateUserFcmToken, getUserHistoricalResults, createAppFeedback } from "../../user.model.js";
import { processAndUploadAvatar } from "../services/image.service.js";
import { handleAdminPreferenceChangeNotification } from "../../../M9_Notification/engine/notification.engine.js";
import { sendPreferenceChangeEmail } from "../../../../email_templates/email.service.js";
import * as userValidator from "../validator/user.validator.js";
import { resolveSubscription, resolveUnlockedExam } from "../../../../utils/helpers.js";

export const getProfileController = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (userId && userId.toString().startsWith('demo-user-')) {
      const demoUser = {
        id: userId,
        full_name: req.user.role === 'admin' ? 'Admin User' : (req.user.subscription === 'premium' ? 'Maw (Demo Premium)' : 'Wasay (Demo Free)'),
        email: req.user.role === 'admin' ? 'ragesr56@gmail.com' : (req.user.subscription === 'premium' ? 'mawbsds@gmail.com' : 'abdulwasaybaloch5@gmail.com'),
        role: req.user.role || 'user',
        subscription: req.user.subscription || 'free',
        preference: req.user.preference || 'IELTS',
        bio: 'Demo Mode Profile',
        avatar_url: null,
      };
      return res.status(200).json({ success: true, user: demoUser });
    }
    const user = await findUserById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.status(200).json({
      success: true,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        bio: user.bio,
        avatar_url: user.avatar_url,
        role: user.role,
        preference: user.preference,
        subscription: resolveSubscription(user),
        unlocked_exam: resolveUnlockedExam(user),
        is_email_verified: user.is_email_verified,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
    });
  } catch (error) {
    if (req.user?.id?.toString().startsWith('demo-user-')) {
      return res.status(200).json({
        success: true,
        user: {
          id: req.user.id,
          full_name: 'Demo User',
          email: 'demo@testiva.app',
          role: req.user.role || 'user',
          subscription: req.user.subscription || 'free',
          preference: req.user.preference || 'IELTS',
        }
      });
    }
    res.status(500).json({ success: false, message: "Failed to fetch profile" });
  }
};

export const getAllResults = async (req, res) => {
  try {
    const userId = req.user.id;
    const results = await getUserHistoricalResults(userId);
    res.status(200).json({ success: true, data: results });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to fetch historical results" });
  }
};

export const updateProfileController = async (req, res) => {
  try {
    const { error, value } = userValidator.updateProfileSchema.validate(req.body);
    if (error) {
      console.log("Validation Schema Error Details:", error.details[0]);
      return res.status(400).json({ success: false, message: error.details[0].message });
    }
    const userId = req.user.id;
    const updatedUser = await updateUserProfile(userId, value);
    res.status(200).json({ success: true, message: "Profile updated successfully", user: updatedUser });
  } catch (err) {
    if (err.message === "User not found") {
      return res.status(404).json({ success: false, message: err.message });
    }
    console.log("Error in Profile Controller : ", err.message);
    res.status(500).json({ success: false, message: "Profile update failed" });
  }
};

export const changePasswordController = async (req, res) => {
  try {
    const { error, value } = userValidator.changePasswordSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, message: error.details[0].message });
    }
    const userId = req.user.id;
    const updatedUser = await updateUserPassword(userId, value);
    res.status(200).json({ success: true, message: "Password changed successfully", user: updatedUser });
  } catch (err) {
    if (err.message === "User not found" || err.message === "Current password is incorrect" || err.message === "Passwords do not match") {
      return res.status(400).json({ success: false, message: err.message });
    }
    res.status(500).json({ success: false, message: "Password change failed" });
  }
};

export const uploadAvatarController = async (req, res) => {
  try {
    const userId = req.user.id;
    if (!req.file) {
      return res.status(400).json({ success: false, message: "No image uploaded" });
    }
    const avatarURL = await processAndUploadAvatar(req.file.buffer);
    const user = await uploadUserAvatar(userId, avatarURL);
    res.status(200).json({ success: true, message: "Avatar uploaded successfully", user });
  } catch (error) {
    res.status(500).json({ success: false, message: "Avatar upload failed" });
  }
};

export const updateFcmTokenController = async (req, res) => {
  try {
    const userId = req.user.id;
    const { fcm_token } = req.body;
    if (!fcm_token) {
      return res.status(400).json({ success: false, message: "FCM token is required" });
    }
    const updatedUser = await updateUserFcmToken(userId, fcm_token);
    res.status(200).json({ success: true, message: "FCM token updated successfully", updatedUser });
  } catch (error) {
    if (error.message === "User not found") {
      return res.status(404).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: "Failed to update FCM token" });
  }
};

export const requestPreferenceChangeController = async (req,res)=> {
  try {
    const userID = req.user.id;
    const { feedback, targetPreference} = req.body;
    if (!feedback || feedback.trim().length < 10) return res.status(400).json({
      success: false,
      message: 'Please Provide a valid feedback'
    })
    if (!targetPreference || !["IELTS", "PTE"].includes(targetPreference)) return res.status(400).json({
      success: false,
      message: 'Please Provide a Valid Target Preference'  
    })
    const user = await findUserById(userID);
    if (!user) {
      return res.status(404).json({ success: false, message: "User profile record missing." });
    }
    if (user.preference === targetPreference) {
      return res.status(400).json({ success: false, message: `Your preference profile status is already explicitly mapped to ${targetPreference}` });
    }
    const adminQuery = await pool.query("SELECT id, email FROM users WHERE role = 'admin' LIMIT 1");
    const adminUser = adminQuery.rows[0];
    const adminEmailAddress = adminUser ? adminUser.email : process.env.EMAIL_USER;
    await sendPreferenceChangeEmail({
      adminEmail: adminEmailAddress,
      userName: user.full_name,
      userEmail: user.email,
      currentPreference: user.preference,
      targetPreference,
      feedback
    });
    await handleAdminPreferenceChangeNotification(req.io, { user, targetPreference, feedback }).catch(console.error);
    res.status(200).json({
      success: true,
      message: 'Your preference change request has been sent to Admin.'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Internal Server Error'
    });
  }
};

export const submitAppFeedbackController = async (req, res) => {
  try {
    const { error, value } = userValidator.submitAppFeedbackSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, message: error.details[0].message });
    }
    const feedback = await createAppFeedback({
      userId: req.user.id,
      rating: value.rating,
      category: value.category,
      comment: value.comment,
    });
    return res.status(201).json({
      success: true,
      message: "Feedback submitted successfully",
      data: feedback,
    });
  } catch (err) {
    console.log("Error in submitAppFeedbackController:", err.message);
    return res.status(500).json({ success: false, message: "Failed to submit feedback" });
  }
};
