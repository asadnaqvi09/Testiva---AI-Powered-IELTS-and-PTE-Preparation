import jwt from "jsonwebtoken";

export const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

export const generateGuestToken = () => {
  return jwt.sign(
    { role: "guest" },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_GUEST_EXPIRES_IN }
  );
};