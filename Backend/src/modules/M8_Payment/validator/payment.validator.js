import Joi from "joi";

export const createCheckoutSchema = Joi.object({
  plan: Joi.string()
    .valid("basic_ielts", "basic_pte", "premium")
    .required(),
  success_url: Joi.string().uri().optional(),
  cancel_url: Joi.string().uri().optional(),
});
