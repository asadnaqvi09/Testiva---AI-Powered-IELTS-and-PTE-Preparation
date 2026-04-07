import Joi from 'joi';

export const createTestSchema = Joi.object({
    title: Joi.string().min(5).max(255).trim().required().messages({
        'string.empty': 'Test title cannot be empty',
        'string.min': 'Title should be at least 5 characters long'
    }),
    exam_type: Joi.string().valid('IELTS', 'PTE').required(),
    is_full_mock: Joi.boolean().default(false),
    total_time_minutes: Joi.number().integer().min(1).max(300).required(),
    sections: Joi.array().items(
        Joi.object({
            section_name: Joi.string().valid(
                'Reading', 
                'Listening', 
                'Writing', 
                'Speaking', 
                'Speaking & Writing' // PTE support ke liye ye zaroori hai
            ).required(),
            time_limit_minutes: Joi.number().integer().min(1).required(),
            order_number: Joi.number().integer().min(1).required(),
            instructions: Joi.string().allow('', null),
            questions: Joi.array().items(
                Joi.object({
                    question_type: Joi.string().required(), // e.g., 'MCQ', 'Essay'
                    question_text: Joi.string().required(),
                    passage_text: Joi.string().allow('', null),
                    options: Joi.array().items(Joi.string()).optional(), // JSONB mapped
                    correct_answer: Joi.string().allow('', null),
                    audio_url: Joi.string().uri().allow('', null),
                    order_number: Joi.number().integer().min(1).required(),
                    marks: Joi.number().integer().min(1).default(1)
                })
            ).min(1).required()
        })
    ).min(1).required()
});