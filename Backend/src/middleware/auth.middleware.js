import jwt from "jsonwebtoken";
import redis from "redis";

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
    const isBlackListed = await redis.get(`bl:${token}`);
    if (isBlackListed) return res.status(401).json({
      success : false,
      message : "Token revoked"
    })
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );
    req.user = {
      id : decoded.id,
      role : decoded.role,
      subscription : decoded.subscription
    };
    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};