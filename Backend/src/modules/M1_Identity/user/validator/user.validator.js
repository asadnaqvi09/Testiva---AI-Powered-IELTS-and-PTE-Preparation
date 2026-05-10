import Joi from "joi";

const passwordSchema = Joi.string()
  .pattern(new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])"))
  .min(8)
  .max(128)
  .required();

export const updateProfileSchema = Joi.object({
  full_name: Joi.string().trim().min(2).max(100).required(),
  bio: Joi.string().trim().max(500).allow("").optional(),
  preferences: Joi.string().valid("IELTS", "PTE").optional()
});

export const changePasswordSchema = Joi.object({
  current_password: Joi.string().required(),
  new_password: passwordSchema,
  confirm_password: Joi.string().valid(Joi.ref("new_password")).required()
});