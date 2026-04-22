import sharp from "sharp";
import { fileTypeFromBuffer } from "file-type";
import cloudinary from "../../config/cloudinary.js";

export const processAndUploadAvatar = async (fileBuffer) => {
  const type = await fileTypeFromBuffer(fileBuffer);
  if (!type || !["image/jpeg", "image/png"].includes(type.mime)) {
    throw new Error("Incompatible file type. Only JPEG and PNG are allowed.");
  }
  let processedImage;
  if (type.mime === "image/png") {
    processedImage = await sharp(fileBuffer).resize(300, 300).png().toBuffer();
  } else {
    processedImage = await sharp(fileBuffer).resize(300, 300).jpeg({ quality: 80 }).toBuffer();
  }
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: "testiva/avatars" },
      (error, result) => {
        if (error) reject(error);
        else resolve(result.secure_url);
      }
    );
    uploadStream.end(processedImage);
  });
};