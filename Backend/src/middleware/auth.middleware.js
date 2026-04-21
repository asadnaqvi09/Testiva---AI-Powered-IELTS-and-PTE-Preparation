import jwt from "jsonwebtoken";
import {redisClient} from "../config/redis.js";

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Authorization token missing",
      });
    }
    const token = authHeader.split(" ")[1];
    const isBlackListed = await redisClient.get(`bl:${token}`);
    if (isBlackListed) {
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
      subscription: decoded.subscription || "free",
      tokenVersion: decoded.tokenVersion || 0,
      isGuest: decoded.isGuest || false,
    };
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};