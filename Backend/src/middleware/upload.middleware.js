import multer from "multer";
const storage = multer.memoryStorage();

const allowedImageTypes = ["image/jpeg", "image/png", "image/webp"];
const allowedAudioTypes = [
  "audio/mpeg",
  "audio/mp3",
  "audio/wav",
  "audio/x-wav",
  "audio/mp4",
  "audio/m4a",
  "audio/x-m4a",
  "audio/aac",
  "audio/webm",
  "audio/ogg",
  "audio/flac",
];

const audioExtOk = (name = "") =>
  /\.(mp3|wav|m4a|mp4|aac|ogg|webm|flac)$/i.test(name);

const fileFilter = (req, file, cb) => {
  if (allowedImageTypes.includes(file.mimetype) || allowedAudioTypes.includes(file.mimetype)) {
    cb(null, true);
    return;
  }
  // Flutter / some clients send octet-stream for m4a recordings.
  if (file.mimetype === "application/octet-stream" && audioExtOk(file.originalname)) {
    cb(null, true);
    return;
  }
  cb(new Error("Invalid file type. Only Images and Audio allowed."), false);
};

const pdfFileFilter = (req, file, cb) => {
  if (file.mimetype === 'application/pdf') {
    cb(null, true);
  } else {
    cb(new Error('Only PDF files are allowed!'), false);
  }
}

export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024
  }
});

export const fileUpload = multer({
  storage: storage,
  fileFilter: pdfFileFilter,
});