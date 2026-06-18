import bcrypt from "bcrypt";

export const hashPassword = async (password) => {
  return await bcrypt.hash(password, 10);
};

export const hashOTP = async (otp) => {
  return await bcrypt.hash(String(otp), 10);
};

export const compareOTP = async (otp, hashedOTP) => {
  return await bcrypt.compare(String(otp), hashedOTP);
};

export const generateOTP = () => {
  return Math.floor(1000 + Math.random() * 9000).toString();
};

export const resolveSubscription = (user) => {
  return user.role === "admin" ? "premium" : user.subscription;
};

export const sendError = (res, err) => res.status(err.statusCode || 500).json({
  success: false,
  message: err.message || 'Internal server error',
  errors: err.errors || [],
});

export const buildPagination = ({ page, limit, total }) => {
  const totalPages = Math.ceil(total / limit) || 1;
  return {
    page,
    limit,
    total,
    pages: totalPages,
    totalPages,
  };
};