import Joi from 'joi';

const partSchema = Joi.object({
    part_title: Joi.string().trim().min(3).max(255).required(),
    part_content: Joi.string().trim().min(10).required(),
    order_index: Joi.number().integer().min(1).required()
});

const mediaSchema = Joi.object({
    file_url: Joi.string().uri().required(),
    file_name: Joi.string().trim().max(255).required(),
    file_size: Joi.number().integer().min(1).optional(),
    file_type: Joi.string().valid('application/pdf').default('application/pdf').optional()
});

export const createPreparationSchema = Joi.object({
    title: Joi.string().trim().min(5).max(255).required(),
    test_type: Joi.string().valid('IELTS', 'PTE').required(),
    section: Joi.string().valid('Reading', 'Listening', 'Writing', 'Speaking').required(),
    summary: Joi.string().trim().max(1000).allow('', null).optional(),
    status: Joi.string().valid('draft', 'published').default('draft'),
    parts: Joi.array().items(partSchema).min(1).required(),
    media: Joi.array().items(mediaSchema).optional()
}).unknown(false);

export const updatePreparationSchema = Joi.object({
    title: Joi.string().trim().min(5).max(255).optional(),
    test_type: Joi.string().valid('IELTS', 'PTE').optional(),
    section: Joi.string().valid('Reading', 'Listening', 'Writing', 'Speaking').optional(),
    summary: Joi.string().trim().max(1000).allow('', null).optional(),
    status: Joi.string().valid('draft', 'published').optional(),
    parts: Joi.array().items(partSchema).optional(),
    media: Joi.array().items(mediaSchema).optional()
}).min(1).unknown(false);

export const preparationFilterSchema = Joi.object({
    test_type: Joi.string().valid('IELTS', 'PTE').optional(),
    section: Joi.string().valid('Reading', 'Listening', 'Writing', 'Speaking').optional(),
    search: Joi.string().trim().max(255).optional()
}).unknown(false);

export const uploadPdfSchema = Joi.object({
    file: Joi.object().required(),
    userId: Joi.string().uuid().required()
}).unknown(false);