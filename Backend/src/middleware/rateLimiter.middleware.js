import rateLimit from "express-rate-limit";

const isDev = process.env.NODE_ENV !== "production";

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: isDev ? 100 : 10,
  message: {
    success: false,
    message: "Too many requests, try again later"
  },
  standardHeaders: true,
  legacyHeaders: false
});

export const passwordResetLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 3,
  message: {
    success: false,
    message: "Too many requests, try again later"
  },
})

export const otpLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  max: 3,
  message: {
    success: false,
    message: "Too many OTP requests, wait 5 minutes"
  }
});

export const aiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 40,
  message: {
    success: false,
    message:"Hourly limit reached for AI feedback,Try Again later"
  }
})

export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 400,
  standardHeaders: true,
  legacyHeaders: false,
});

export const writeLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
});
