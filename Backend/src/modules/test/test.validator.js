import Joi from 'joi';

const questionSchema = Joi.object({
    question_type: Joi.string().valid(
        'mcq', 'true_false', 'fill_blank', 'essay', 'audio_recording', 'cue_card', 'matching'
    ).required(),
    question_text: Joi.string().required(),
    passage_text: Joi.string().allow('', null),
    options: Joi.array().items(Joi.string()).when('question_type', {
        is: Joi.valid('mcq', 'true_false', 'matching'),
        then: Joi.required(),
        otherwise: Joi.optional().default(null)
    }),
    correct_answer: Joi.string().allow('', null).required(),
    audio_url: Joi.string().uri().allow('', null),
    order_number: Joi.number().integer().min(1).required(),
    marks: Joi.number().integer().min(1).default(1)
});

export const createTestSchema = Joi.object({
    title: Joi.string().min(5).max(255).trim().required(),
    exam_type: Joi.string().valid('IELTS', 'PTE').required(),
    is_full_mock: Joi.boolean().default(false),
    total_time_minutes: Joi.number().integer().min(0).default(0),
    sections: Joi.array().items(
        Joi.object({
            section_name: Joi.string().when(Joi.ref('...exam_type'), {
                is: 'PTE',
                then: Joi.valid('Reading', 'Listening', 'Speaking & Writing'),
                otherwise: Joi.valid('Reading', 'Listening', 'Writing', 'Speaking')
            }).required(),
            time_limit_minutes: Joi.number().integer().min(1).required(),
            order_number: Joi.number().integer().min(1).required(),
            instructions: Joi.string().allow('', null),
            questions: Joi.array().items(questionSchema).min(1).required()
        })
    ).min(1).required()
});

export const updateHeaderSchema = Joi.object({
    title: Joi.string().min(5).max(255).optional(),
    is_full_mock: Joi.boolean().optional()
}).min(1);

export const updateQuestionSchema = Joi.object({
    question_type: Joi.string().valid(
        'mcq', 'true_false', 'fill_blank', 'essay', 'audio_recording', 'cue_card', 'matching'
    ).optional(),
    question_text: Joi.string().optional(),
    passage_text: Joi.string().allow('', null).optional(),
    options: Joi.array().items(Joi.string()).optional(),
    correct_answer: Joi.string().allow('', null).optional(),
    audio_url: Joi.string().uri().allow('', null).optional(),
    marks: Joi.number().integer().min(1).optional()
}).min(1);