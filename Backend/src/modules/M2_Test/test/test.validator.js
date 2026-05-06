import Joi from 'joi';

const questionSchema = Joi.object({
    question_type: Joi.string().valid('mcq', 'fill_blank', 'short_answer', 'essay').required(),
    question_text: Joi.string().required(),
    passage_text: Joi.string().allow('', null),
    options: Joi.array().items(Joi.string()).when('question_type', {
        is: 'mcq',
        then: Joi.required(),
        otherwise: Joi.optional()
    }),
    correct_answer: Joi.string().allow('', null),
    audio_url: Joi.string().uri().allow('', null),
    image_url: Joi.string().uri().allow('', null),
    order_number: Joi.number().integer().min(1).required(),
    marks: Joi.number().integer().min(1).default(1),
    difficulty: Joi.string().valid('easy', 'medium', 'hard', 'mixed').default('medium')
});

export const createTestSchema = Joi.object({
    title: Joi.string().min(5).max(255).trim().required(),
    exam_type: Joi.string().valid('IELTS', 'PTE').required(),
    test_category: Joi.string().valid('full_mock', 'module_wise').required(),
    difficulty_level: Joi.string().valid('easy', 'medium', 'hard', 'mixed').default('mixed'),
    passing_score: Joi.number().min(0).required(),
    sections: Joi.array().items(
        Joi.object({
            section_name: Joi.string().valid(
                'Reading', 'Listening', 'Writing', 'Speaking', 'Speaking & Writing'
            ).required(),
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
    question_type: Joi.string().valid('mcq', 'fill_blank', 'short_answer', 'essay').optional(),
    question_text: Joi.string().optional(),
    passage_text: Joi.string().allow('', null).optional(),
    options: Joi.array().items(Joi.string()).optional(),
    correct_answer: Joi.string().allow('', null).optional(),
    audio_url: Joi.string().uri().allow('', null).optional(),
    image_url: Joi.string().uri().allow('', null).optional(),
    order_number: Joi.number().integer().min(1).optional(),
    marks: Joi.number().integer().min(1).optional(),
    difficulty: Joi.string().valid('easy', 'medium', 'hard', 'mixed').optional()
}).min(1);

export const addQuestionSchema = Joi.object({
    section_id: Joi.string().uuid().required(),
    question_type: Joi.string().valid('mcq', 'fill_blank', 'short_answer', 'essay').required(),
    question_text: Joi.string().required(),
    passage_text: Joi.string().allow(null, ''),
    options: Joi.array().items(Joi.string()).optional(),
    correct_answer: Joi.string().allow(null, ''),
    audio_url: Joi.string().uri().allow(null, ''),
    image_url: Joi.string().uri().allow(null, ''),
    order_number: Joi.number().integer().required(),
    marks: Joi.number().integer().default(1),
    difficulty: Joi.string().valid('easy', 'medium', 'hard', 'mixed').default('medium')
});