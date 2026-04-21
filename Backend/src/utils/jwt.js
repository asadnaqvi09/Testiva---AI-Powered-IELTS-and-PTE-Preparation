import jwt from "jsonwebtoken";
import { randomUUID } from "crypto";

export const generateAccessToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

export const generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId, tokenId: randomUUID() },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN }
  );
};

export const verifyRefreshToken = (token) => {
  return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
};

export const generateGuestToken = () => {
  return jwt.sign(
    {
      id: randomUUID(),
      role: "guest",
      subscription: "free",
      isGuest: true
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_GUEST_EXPIRES_IN
    }
  );
};