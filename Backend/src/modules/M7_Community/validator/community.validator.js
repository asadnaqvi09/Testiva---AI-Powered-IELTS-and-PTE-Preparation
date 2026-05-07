import Joi from 'joi';

const VALID_TAGS = ['IELTS', 'PTE', 'General'];
const VALID_PLATFORMS = ['twitter', 'instagram', 'whatsapp', 'facebook', 'copy_link'];
const VALID_FILTERS = ['clean', 'flagged'];

const uuid = Joi.string().uuid();

const title = Joi.string().trim().min(5).max(200).messages({
  'string.min': 'title must be 5–200 characters',
  'string.max': 'title must be 5–200 characters',
});

const content = Joi.string().trim().min(10).max(5000).messages({
  'string.min': 'content must be 10–5000 characters',
  'string.max': 'content must be 10–5000 characters',
});

const commentContent = Joi.string().trim().min(1).max(2000).messages({
  'string.min': 'comment must be 1–2000 characters',
  'string.max': 'comment must be 1–2000 characters',
});

const reason = Joi.string().trim().max(500).allow('', null);

const validate = (schema, data) => {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    const err = new Error('Validation Error');

    err.statusCode = 400;
    err.errors = error.details.map((e) => e.message);

    throw err;
  }

  return value;
};

export const validateCreatePost = (data) =>
  validate(
    Joi.object({
      topic_tag: Joi.string()
        .valid(...VALID_TAGS)
        .required()
        .messages({
          'any.only': `topic_tag must be one of: ${VALID_TAGS.join(', ')}`,
        }),

      title: title.required(),
      content: content.required(),
    }),
    data
  );

export const validateUpdatePost = (data) =>
  validate(
    Joi.object({
      title,
      content,
    }).min(1),
    data
  );

export const validatePostId = (params) =>
  validate(
    Joi.object({
      postId: uuid.required().messages({
        'string.guid': 'Invalid post ID',
      }),
    }),
    params
  );

export const validateCreateComment = (data) =>
  validate(
    Joi.object({
      content: commentContent.required(),

      parent_id: uuid.allow(null).messages({
        'string.guid': 'Invalid parent_id',
      }),
    }),
    data
  );

export const validateUpdateComment = (data) =>
  validate(
    Joi.object({
      content: commentContent.required(),
    }),
    data
  );

export const validateCommentId = (params) =>
  validate(
    Joi.object({
      commentId: uuid.required().messages({
        'string.guid': 'Invalid comment ID',
      }),
    }),
    params
  );

export const validateGetPosts = (query) =>
  validate(
    Joi.object({
      topic_tag: Joi.string()
        .valid('All', ...VALID_TAGS)
        .messages({
          'any.only': 'Invalid topic_tag',
        }),

      filter: Joi.string()
        .valid(...VALID_FILTERS)
        .messages({
          'any.only': 'filter must be clean or flagged',
        }),

      search: Joi.string().trim().max(100),

      page: Joi.number().integer().min(1).messages({
        'number.base': 'page must be a number',
        'number.min': 'page must be a positive integer',
      }),

      limit: Joi.number().integer().min(1).max(50).messages({
        'number.min': 'limit must be between 1 and 50',
        'number.max': 'limit must be between 1 and 50',
      }),
    }),
    query
  );

export const validateSharePost = (data) =>
  validate(
    Joi.object({
      platform: Joi.string()
        .valid(...VALID_PLATFORMS)
        .required()
        .messages({
          'any.only': `platform must be one of: ${VALID_PLATFORMS.join(', ')}`,
        }),
    }),
    data
  );

export const validateAdminFlagPost = (data) =>
  validate(
    Joi.object({
      reason,
    }),
    data
  );

export const validateAdminDeletePost = (data) =>
  validate(
    Joi.object({
      reason,
    }),
    data
  );