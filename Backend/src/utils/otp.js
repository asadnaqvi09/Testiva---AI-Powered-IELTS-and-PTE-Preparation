import bcrypt from "bcrypt";
import { redisClient } from "../config/redis.js";

const OTP_EXPIRY = 900;

export const storeOTP = async (email, otp, type) => {
  const hashedOTP = await bcrypt.hash(otp.toString(), 10);

  await redisClient.set(
    `otp:${type}:${email}`,
    JSON.stringify({
      otp: hashedOTP,
      attempts: 0,
      is_verified: false
    }),
    { EX: OTP_EXPIRY }
  );
};

export const verifyStoredOTP = async (email, otp, type) => {
  const data = await redisClient.get(`otp:${type}:${email}`);
  if (!data) return { valid: false, message: "OTP expired" };

  const parsed = JSON.parse(data);

  if (parsed.attempts >= 5) {
    await redisClient.del(`otp:${type}:${email}`);
    return { valid: false, message: "Too many attempts" };
  }

  const isMatch = await bcrypt.compare(otp.toString(), parsed.otp);

  if (!isMatch) {
    parsed.attempts += 1;
    await redisClient.set(`otp:${type}:${email}`, JSON.stringify(parsed));
    return { valid: false, message: "Invalid OTP" };
  }

  parsed.is_verified = true;

  await redisClient.set(
    `otp:${type}:${email}`,
    JSON.stringify(parsed)
  );

  return { valid: true };
};

export const checkOTPVerified = async (email, type) => {
  const data = await redisClient.get(`otp:${type}:${email}`);
  if (!data) return false;

  const parsed = JSON.parse(data);
  return parsed.is_verified === true;
};

export const deleteOTP = async (email, type) => {
  await redisClient.del(`otp:${type}:${email}`);
};