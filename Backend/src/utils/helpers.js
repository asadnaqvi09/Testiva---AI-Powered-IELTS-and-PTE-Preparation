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

/**
 * Content unlock track from payment / admin.
 * BOTH = premium (or paid BOTH). Else paid IELTS/PTE. Else fall back to preference.
 */
export const resolveUnlockedExam = (user) => {
  if (!user) return null;
  if (user.role === "admin") return "BOTH";
  if (user.subscription === "premium") return "BOTH";
  const paid = (user.unlocked_exam || "").toString().trim().toUpperCase();
  if (paid === "BOTH" || paid === "IELTS" || paid === "PTE") return paid;
  const pref = (user.preference || "").toString().trim().toUpperCase();
  if (pref === "IELTS" || pref === "PTE") return pref;
  return null;
};

export const getAllowedExamTypes = (user) => {
  const unlocked = resolveUnlockedExam(user);
  if (unlocked === "BOTH") return ["IELTS", "PTE"];
  if (unlocked === "IELTS" || unlocked === "PTE") return [unlocked];
  return [];
};

export const canAccessExamType = (user, examType) => {
  const type = (examType || "").toString().trim().toUpperCase();
  return getAllowedExamTypes(user).includes(type);
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