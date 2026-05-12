import Joi from 'joi';

const questionSchema = Joi.object({
    question_type: Joi.string().required(), // Dynamic types for IELTS/PTE
    question_text: Joi.string().required(),
    passage_text: Joi.string().allow('', null),
    options: Joi.array().items(Joi.any()).default([]), // JSONB
    correct_answer: Joi.any().required(), // JSONB (can be string, object or array)
    audio_url: Joi.string().uri().allow('', null),
    image_url: Joi.string().uri().allow('', null),
    order_number: Joi.number().integer().min(1).required(),
    marks: Joi.number().precision(1).min(0).default(1),
    difficulty: Joi.string().valid('easy', 'medium', 'hard').default('medium'),
    content: Joi.object().default({}), // For complex JSONB PTE tasks
    tags: Joi.array().items(Joi.string()).default([])
});

export const createTestSchema = Joi.object({
    title: Joi.string().min(5).max(255).trim().required(),
    exam_type: Joi.string().valid('IELTS', 'PTE').required(),
    test_category: Joi.string().valid('full_mock', 'module_wise', 'practice').required(),
    difficulty_level: Joi.string().valid('easy', 'medium', 'hard', 'mixed').default('mixed'),
    passing_score: Joi.number().min(0).max(90).required(), // IELTS (0-9) or PTE (0-90)
    total_duration: Joi.number().integer().min(1).required(),
    is_premium: Joi.boolean().default(false),
    sections: Joi.array().items(
        Joi.object({
            section_name: Joi.string().required(),
            section_type: Joi.string().valid('reading', 'listening', 'writing', 'speaking').required(),
            time_limit_minutes: Joi.number().integer().min(1).required(),
            order_number: Joi.number().integer().min(1).required(),
            instructions: Joi.string().allow('', null),
            question_types_allowed: Joi.array().items(Joi.string()).default([]),
            task_count: Joi.number().integer().min(1).default(1),
            questions: Joi.array().items(questionSchema).min(1).required()
        })
    ).min(1).required()
});

export const updateHeaderSchema = Joi.object({
    title: Joi.string().min(5).max(255).optional(),
    test_category: Joi.string().valid('full_mock', 'module_wise').optional(),
    is_published: Joi.boolean().optional(),
    difficulty_level: Joi.string().valid('easy', 'medium', 'hard', 'mixed').optional(),
    passing_score: Joi.number().min(0).optional()
}).min(1);

export const updateQuestionSchema = Joi.object({
    question_type: Joi.string().optional(),
    question_text: Joi.string().optional(),
    passage_text: Joi.string().allow('', null).optional(),
    options: Joi.array().items(Joi.any()).optional(),
    correct_answer: Joi.any().optional(),
    audio_url: Joi.string().uri().allow('', null).optional(),
    image_url: Joi.string().uri().allow('', null).optional(),
    order_number: Joi.number().integer().optional(),
    marks: Joi.number().precision(1).optional(),
    difficulty: Joi.string().valid('easy', 'medium', 'hard').optional(),
    content: Joi.object().optional(),
    tags: Joi.array().items(Joi.string()).optional()
}).min(1);

export const addQuestionSchema = questionSchema.keys({
    section_id: Joi.string().uuid().required()
});