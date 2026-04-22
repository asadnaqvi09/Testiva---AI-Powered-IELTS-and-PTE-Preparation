import Joi from "joi";

export const updateProfileSchema = Joi.object({
  full_name: Joi.string().min(2).max(100).required(),
  bio: Joi.string().max(500).allow("").optional()
});

export const changePasswordSchema = Joi.object({
  current_password: Joi.string().required(),
  new_password: Joi.string()
    .pattern(new RegExp("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])"))
    .min(8)
    .max(128)
    .required(),
  confirm_password: Joi.string().valid(Joi.ref("new_password")).required()
});