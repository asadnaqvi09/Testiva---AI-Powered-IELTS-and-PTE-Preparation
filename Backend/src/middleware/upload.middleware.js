import multer from 'multer';

const storage = multer.memoryStorage();

const fileFilter = (req,file,cb) => {
    const allowedTypes = ["image/jpeg", "image/png" , "image/webp"];
    if (!allowedTypes.includes(file.mimetype)) {
        return cb(
            new Error ("Only JPEG,PNG,WEBP are files are allowed")
        )
    }
    cb (null,true);
}

export const uploadAvatar = multer({
    storage,
    fileFilter,
    limits: {
        fieldSize: 2 * 1024 * 1024
    }
});