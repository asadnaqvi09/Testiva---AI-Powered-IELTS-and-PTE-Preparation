import Joi from "joi";

const responseItem = Joi.object({
  question_id: Joi.string().uuid().required(),
  user_answer: Joi.any().required(),
  audio_response_url: Joi.string().uri().allow("", null).optional(),
  audio_url: Joi.string().uri().allow("", null).optional(),
  time_spent_seconds: Joi.number().integer().min(0).default(0),
  time_taken_seconds: Joi.number().integer().min(0).optional(),
  word_count: Joi.number().integer().min(0).default(0),
  client_created_at: Joi.date().default(() => new Date()),
});

export const startAttemptSchema = Joi.object({
  test_id: Joi.string().uuid().required(),
  client_started_at: Joi.date().required(),
  is_offline: Joi.boolean().default(false),
});

export const saveResponseSchema = Joi.object({
  attempt_id: Joi.string().uuid().required(),
}).concat(responseItem);

export const submitFullTestSchema = Joi.object({
  test_id: Joi.string().uuid().required(),
  client_started_at: Joi.date().required(),
  client_completed_at: Joi.date().required(),
  is_offline: Joi.boolean().default(false),
  overall_band_score: Joi.number().optional(),
  reading_score: Joi.number().optional(),
  listening_score: Joi.number().optional(),
  writing_score: Joi.number().optional(),
  speaking_score: Joi.number().optional(),
  feedback: Joi.string().allow("", null).optional(),
  responses: Joi.array().items(responseItem).min(1).required(),
});
