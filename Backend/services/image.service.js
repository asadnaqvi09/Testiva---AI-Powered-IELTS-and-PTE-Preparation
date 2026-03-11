import sharp from "sharp";
import cloudinary from "../config/cloudinary.js";

export const processAndUploadAvatar = async (fileBuffer) => {
    const processImage = await sharp(fileBuffer).resize(300,300).jpeg({ quality: 80}).toBuffer();
    return new Promise((resolve,reject) => {
        const UploadStream = cloudinary.uploader.upload_stream(
            {
                folder : "testiva/avatars",
                transformation: [
                    { width: 300 , height: 300, crop: "fill" }
                ]
            },
            (error,result) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(result.secure_url);
                }
            }
        );
        UploadStream.end(processImage);
    });
}