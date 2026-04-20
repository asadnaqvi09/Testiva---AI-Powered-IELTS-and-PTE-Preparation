import jwt from "jsonwebtoken";
import { randomUUID } from "crypto";

export const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

export const generateGuestToken = () => {
  return jwt.sign(
    { id: randomUUID(),role: "guest", subscription: "free" },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_GUEST_EXPIRES_IN }
  );
};