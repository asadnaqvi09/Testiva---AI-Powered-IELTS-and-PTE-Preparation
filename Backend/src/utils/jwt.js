import jwt from "jsonwebtoken";
import { randomUUID } from "crypto";

export const generateAccessToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "15m",
  });
};

export const generateRefreshToken = (userId, tokenVersion = 0) => {
  return jwt.sign(
    { userId, tokenId: randomUUID(), tokenVersion: Number(tokenVersion) || 0 },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || "7d" }
  );
};

export const verifyRefreshToken = (token) => {
  return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
};

/** Seconds until JWT exp (min 1). Falls back to 900s if exp missing. */
export const getTokenTtlSeconds = (token) => {
  try {
    const decoded = jwt.decode(token);
    if (decoded?.exp) {
      return Math.max(decoded.exp - Math.floor(Date.now() / 1000), 1);
    }
  } catch {
    /* ignore */
  }
  return 900;
};