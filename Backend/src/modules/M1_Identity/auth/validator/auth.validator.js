import Joi from "joi";

const passwordSchema = Joi.string()
  .pattern(new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])"))
  .min(8)
  .max(128)
  .required();

const preferenceSchema = Joi.string()
  .valid("IELTS", "PTE")
  .optional();

export const registerSchema = Joi.object({
  full_name: Joi.string().trim().min(3).max(150).required(),
  email: Joi.string().email().lowercase().required(),
  password: passwordSchema,
  confirm_password: Joi.string().valid(Joi.ref("password")).required(),
  preferences: preferenceSchema
});

export const loginSchema = Joi.object({
  email: Joi.string().email().lowercase().required(),
  password: Joi.string().required()
});

export const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().lowercase().required()
});

export const resetPasswordSchema = Joi.object({
  email: Joi.string().email().lowercase().required(),
  new_password: passwordSchema,
  confirm_password: Joi.string().valid(Joi.ref("new_password")).required()
});

export const otpSchema = Joi.object({
  email: Joi.string().email().lowercase().required(),
  otp: Joi.string().length(4).pattern(/^\d+$/).required(),
  type: Joi.string().valid("register", "reset").required(),
  preference: preferenceSchema
});

export const resendOtpSchema = Joi.object({
  email: Joi.string().email().lowercase().required(),
  type: Joi.string().valid("register", "reset").required()
});