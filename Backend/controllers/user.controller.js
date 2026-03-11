import { findUserById,updateUserProfile, uploadUserAvatar } from '../models/user.model.js';
import { processAndUploadAvatar } from "../services/image.service.js";

export const getProfileController = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await findUserById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }
    res.status(200).json({
      success: true,
      user
    });
  } catch (error) {
    console.error("Profile Fetch Error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch profile"
    });
  }
};

export const updateProfileController = async (req, res) => {
  try {
    const userId = req.user.id;
    const { full_name, country } = req.body;
    const updatedUser = await updateUserProfile(
      userId,
      { full_name, country }
    );
    res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      user: updatedUser
    });
  } catch (error) {
    console.error("Profile Update Error:", error);
    res.status(500).json({
      success: false,
      message: "Profile update failed"
    });
  }
};

export const uploadAvatarController = async (req,res) => {
  try {
    const userId = req.user.id;
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No Image Upload"
      })
    };
    const avatarURL = await  processAndUploadAvatar(req.file.buffer);
    const user = await uploadUserAvatar(userId,avatarURL);
    res.status(200).json({
      success: true,
      message: "Avatar Uploaded Successfully",
      user
    })
  } catch (error) {
    console.error("Error in UploadAvatar", error);
    return res.status(500).json({
      success: false,
      message: "Upload Avatar Failed"
    })
  }
}