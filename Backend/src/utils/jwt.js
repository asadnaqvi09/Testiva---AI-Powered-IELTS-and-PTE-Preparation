import jwt from "jsonwebtoken";

const NIL_UUID = "00000000-0000-0000-0000-000000000000";

export const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};

export const generateGuestToken = () => {
  return jwt.sign(
    { id: NIL_UUID,role: "guest", subscription: "free" },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_GUEST_EXPIRES_IN }
  );
};