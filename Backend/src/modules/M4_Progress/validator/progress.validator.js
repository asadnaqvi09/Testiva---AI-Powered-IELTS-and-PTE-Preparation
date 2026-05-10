import Joi from 'joi';

const responseSchema = Joi.object({
    question_id: Joi.string().uuid().required(),
    user_answer: Joi.alternatives().try(Joi.string(), Joi.number()).required(),
    audio_url: Joi.string().uri().allow('', null).optional(),
    time_taken_seconds: Joi.number().integer().min(0).allow(null).optional(),
    client_created_at: Joi.date().iso().optional()
});

export const submitTestSchema = Joi.object({
    test_id: Joi.string().uuid().required(),
    client_started_at: Joi.date().iso().required(),
    client_completed_at: Joi.date().iso().required(),
    is_offline: Joi.boolean().default(false),
    responses: Joi.array().items(responseSchema).min(1).required()
});