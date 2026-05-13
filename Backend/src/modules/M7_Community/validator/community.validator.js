import Joi from 'joi';

// Must match the strings used in presence.service and controller (UPPERCASE)
const VALID_TAGS = ['IELTS', 'PTE', 'GENERAL'];
const VALID_PLATFORMS = ['twitter', 'instagram', 'whatsapp', 'facebook', 'copy_link'];
const VALID_FILTERS = ['clean', 'flagged'];

const uuid = Joi.string().uuid();

const title = Joi.string().trim().min(5).max(200).messages({
  'string.min': 'Title must be 5–200 characters',
  'string.max': 'Title must be 5–200 characters',
});

const content = Joi.string().trim().min(10).max(5000).messages({
  'string.min': 'Content must be 10–5000 characters',
  'string.max': 'Content must be 10–5000 characters',
});

const commentContent = Joi.string().trim().min(1).max(2000).messages({
  'string.min': 'Comment must be 1–2000 characters',
  'string.max': 'Comment must be 1–2000 characters',
});

const reason = Joi.string().trim().max(500).allow('', null);

/**
 * Generic validation runner
 */
const validate = (schema, data) => {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true, // Crucial to prevent SQL injection/junk data
  });

  if (error) {
    const err = new Error('Validation Error');
    err.statusCode = 400;
    err.errors = error.details.map((e) => e.message);
    throw err;
  }

  return value;
};

// --- Post Validations ---

export const validateCreatePost = (data) =>
  validate(
    Joi.object({
      topic_tag: Joi.string()
        .uppercase() // Force uppercase to match logic
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
    }).min(1), // Ensure at least one field is provided
    data
  );

export const validatePostId = (params) =>
  validate(
    Joi.object({
      postId: uuid.required().messages({
        'string.guid': 'Invalid post ID format',
      }),
    }),
    params
  );

// --- Comment Validations ---

export const validateCreateComment = (data) =>
  validate(
    Joi.object({
      content: commentContent.required(),
      parent_id: uuid.allow(null).messages({
        'string.guid': 'Invalid parent comment ID format',
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
        'string.guid': 'Invalid comment ID format',
      }),
    }),
    params
  );

// --- Query Validations ---

export const validateGetPosts = (query) =>
  validate(
    Joi.object({
      topic_tag: Joi.string()
        .valid('ALL', 'General', 'IELTS', 'PTE')
        .default('ALL')
        .messages({
          'any.only': 'Invalid topic_tag filter',
        }),
      filter: Joi.string()
        .valid('clean', 'flagged')
        .allow('', null),
      search: Joi.string().trim().max(100).allow(''),
      page: Joi.number().integer().min(1).default(1),
      limit: Joi.number().integer().min(1).max(50).default(10),
    }),
    query
  );

// --- Social & Admin Validations ---
export const validateSharePost = (data) =>
  validate(
    Joi.object({
      platform: Joi.string()
        .valid(...VALID_PLATFORMS)
        .required()
        .messages({
          'any.only': `Platform must be one of: ${VALID_PLATFORMS.join(', ')}`,
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