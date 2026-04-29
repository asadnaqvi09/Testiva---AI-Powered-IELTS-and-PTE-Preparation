import Joi from 'joi';

// ==================== LESSON HEADER ====================

export const createLessonSchema = Joi.object({
    title: Joi.string().min(5).max(255).required().messages({
        'string.empty': 'Title is required',
        'string.min': 'Title must be at least 5 characters'
    }),
    test_type: Joi.string().valid('IELTS', 'PTE').required(),
    section: Joi.string().valid('Reading', 'Listening', 'Writing', 'Speaking').required(),
    summary: Joi.string().max(1000).allow('', null).optional(),
    status: Joi.string().valid('draft', 'published').default('draft'),
    min_subscription: Joi.string().valid('free', 'basic', 'premium').default('free'),
    target_band: Joi.number().valid(5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0).default(5.0),
    estimated_minutes: Joi.number().integer().min(5).max(180).default(30),
    tags: Joi.array().items(Joi.string().max(50)).max(10).default([]),
    parts: Joi.array().items(
        Joi.object({
            part_title: Joi.string().min(3).max(255).required(),
            part_content: Joi.string().min(10).required(),
            order_number: Joi.number().integer().min(1).required()
        })
    ).min(1).required()
});

export const updateLessonSchema = Joi.object({
    title: Joi.string().min(5).max(255).optional(),
    test_type: Joi.string().valid('IELTS', 'PTE').optional(),
    section: Joi.string().valid('Reading', 'Listening', 'Writing', 'Speaking').optional(),
    summary: Joi.string().max(1000).allow('', null).optional(),
    status: Joi.string().valid('draft', 'published').optional(),
    min_subscription: Joi.string().valid('free', 'basic', 'premium').optional(),
    target_band: Joi.number().valid(5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0).optional(),
    estimated_minutes: Joi.number().integer().min(5).max(180).optional(),
    tags: Joi.array().items(Joi.string().max(50)).max(10).optional()
}).min(1);

// ==================== LESSON PARTS ====================

export const createPartSchema = Joi.object({
    part_title: Joi.string().min(3).max(255).required(),
    part_content: Joi.string().min(10).required(),
    order_number: Joi.number().integer().min(1).required()
});

export const updatePartSchema = Joi.object({
    part_title: Joi.string().min(3).max(255).optional(),
    part_content: Joi.string().min(10).optional(),
    order_number: Joi.number().integer().min(1).optional()
}).min(1);

// ==================== FILTERS ====================

export const lessonFilterSchema = Joi.object({
    test_type: Joi.string().valid('IELTS', 'PTE').optional(),
    section: Joi.string().valid('Reading', 'Listening', 'Writing', 'Speaking').optional(),
    status: Joi.string().valid('draft', 'published').optional(),
    target_band: Joi.number().valid(5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0).optional()
});