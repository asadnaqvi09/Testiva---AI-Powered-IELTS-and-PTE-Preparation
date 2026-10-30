import sharp from "sharp";
import { fileTypeFromBuffer } from "file-type";
import cloudinary from "../../../../config/cloudinary.js";

export const processAndUploadAvatar = async (fileBuffer) => {
  const type = await fileTypeFromBuffer(fileBuffer);
  let processedImage;
  if (type.mime === "image/png") {
    processedImage = await sharp(fileBuffer).resize(300, 300).png().toBuffer();
  } else if (type.mime === "image/jpeg") {
    processedImage = await sharp(fileBuffer).resize(300, 300).jpeg({ quality: 80 }).toBuffer();
  } else if (type.mime === "image/webp") {
    processedImage = await sharp(fileBuffer).resize(300,300).webp({ quality: 80 }).toBuffer();
  } else {
    throw new Error("Unsupported file type. Only JPEG,PNG and WEBP are allowed")
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

/** L5 — community post image (wider than avatar) */
export const processAndUploadPostImage = async (fileBuffer) => {
  const type = await fileTypeFromBuffer(fileBuffer);
  let processedImage;
  if (type?.mime === "image/png") {
    processedImage = await sharp(fileBuffer)
      .resize({ width: 1600, withoutEnlargement: true })
      .png()
      .toBuffer();
  } else if (type?.mime === "image/jpeg") {
    processedImage = await sharp(fileBuffer)
      .resize({ width: 1600, withoutEnlargement: true })
      .jpeg({ quality: 82 })
      .toBuffer();
  } else if (type?.mime === "image/webp") {
    processedImage = await sharp(fileBuffer)
      .resize({ width: 1600, withoutEnlargement: true })
      .webp({ quality: 82 })
      .toBuffer();
  } else {
    throw new Error("Unsupported file type. Only JPEG, PNG and WEBP are allowed");
  }
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: "testiva/community-posts" },
      (error, result) => {
        if (error) reject(error);
        else resolve(result.secure_url);
      },
    );
    uploadStream.end(processedImage);
  });
};