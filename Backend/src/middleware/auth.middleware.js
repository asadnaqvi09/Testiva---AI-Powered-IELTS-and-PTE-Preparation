import jwt from "jsonwebtoken";
import { redisClient } from "../config/redis.js";

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Access token required",
      });
    }
    const token = authHeader.split(" ")[1];
    let isBlacklisted = null;
    try {
      isBlacklisted = await Promise.race([
        redisClient.get(`bl:${token}`),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error("redis timeout")), 500),
        ),
      ]);
    } catch {
      isBlacklisted = null;
    }
    if (isBlacklisted) {
      return res.status(401).json({
        success: false,
        message: "Token revoked",
      });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.token = token;
    req.user = {
      id: decoded.id,
      role: decoded.role,
      subscription: decoded.subscription ?? "free",
      tokenVersion: decoded.tokenVersion ?? 0,
      preference: decoded.preference ?? null,
    };
    next();
  } catch {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};