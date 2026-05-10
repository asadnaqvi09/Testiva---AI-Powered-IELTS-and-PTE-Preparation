import { findUserById, updateUserProfile, updateUserPassword, uploadUserAvatar, updateUserFcmToken } from "../../user.model.js";
import { processAndUploadAvatar } from "../services/image.service.js";
import * as userValidator from "../validator/user.validator.js";

export const getProfileController = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await findUserById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.status(200).json({ success: true, user });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to fetch profile" });
  }
};

export const updateProfileController = async (req, res) => {
  try {
    const { error, value } = userValidator.updateProfileSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ success: false, message: error.details[0].message });
    }
    const userId = req.user.id;
    const updatedUser = await updateUserProfile(userId, value);
    res.status(200).json({ success: true, message: "Profile updated successfully", user: updatedUser });
  } catch (err) {
    if (err.message === "User not found") {
      return res.status(404).json({ success: false, message: err.message });
    }
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