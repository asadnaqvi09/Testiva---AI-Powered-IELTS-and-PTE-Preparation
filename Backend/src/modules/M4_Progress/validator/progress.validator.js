import Joi from 'joi';

const singleResponse = {
    question_id: Joi.string().uuid().required(),
    user_answer: Joi.any().required(),
    audio_response_url: Joi.string().uri().allow('', null).optional(),
    time_taken_seconds: Joi.number().integer().min(0).default(0),
    client_created_at: Joi.date().iso().default(() => new Date())
};

export const startAttemptSchema = Joi.object({
    test_id: Joi.string().uuid().required(),
    client_started_at: Joi.date().iso().required(),
    is_offline: Joi.boolean().default(false)
});

export const saveResponseSchema = Joi.object({
    attempt_id: Joi.string().uuid().required(),
    ...singleResponse
});

export const submitFullTestSchema = Joi.object({
    test_id: Joi.string().uuid().required(),
    client_started_at: Joi.date().iso().required(),
    client_completed_at: Joi.date().iso().required(),
    is_offline: Joi.boolean().default(false),
    responses: Joi.array().items(Joi.object(singleResponse)).min(1).required()
});