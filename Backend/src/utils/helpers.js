import bcrypt from "bcrypt";

export const hashPassword = async (password) => {
  return await bcrypt.hash(password, 10);
};

export const hashOTP = async (otp) => {
  return await bcrypt.hash(otp,10);
}

export const generateOTP = () => {
  return Math.floor(1000 + Math.random() * 9000).toString();
};

export const resolveSubscription = (user) => {
  return user.role === "admin" ? "premium" : user.subscription;
};