import cloudinary from "../../../config/cloudinary.js";

export const uploadFileToCloudinary = async (fileBuffer, originalName) => {
    return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
            {
                folder: "testiva/documents",
                resource_type: "raw",
                public_id: `${Date.now()}-${originalName.replace(/\s+/g, '_')}`,
                timeout: 60000
            },
            (error, result) => {
                if (error) reject(error);
                else resolve(result);
            }
        );
        uploadStream.end(fileBuffer);
    });
};

export const uploadFileController = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "No file uploaded"
            });
        }
        const result = await uploadFileToCloudinary(
            req.file.buffer,
            req.file.originalname
        );
        return res.status(200).json({
            success: true,
            data: {
                file_url: result.secure_url,
                file_name: req.file.originalname,
                file_size: req.file.size,
                file_type: req.file.mimetype
            },
            message: "File uploaded successfully"
        });
    } catch (error) {
        console.error('Upload error:', error);
        return res.status(500).json({
            success: false,
            message: error.message || "Failed to upload file"
        });
    }
};