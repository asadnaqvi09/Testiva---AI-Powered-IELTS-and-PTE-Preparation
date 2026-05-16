import Joi from "joi";

const questionSchema = Joi.object({
  id: Joi.string().uuid().optional(),
  question_type: Joi.string().max(50).required(),
  sub_question_type: Joi.string().max(50).allow(null, ""),
  passage_text: Joi.string().allow(null, ""),
  question_text: Joi.string().required(),
  word_limit_instruction: Joi.string().allow(null, ""),
  options: Joi.alternatives().try(Joi.array(), Joi.object()).default([]),
  correct_answer: Joi.alternatives().try(Joi.object(), Joi.array(), Joi.string(), Joi.number()).default({}),
  content: Joi.object().default({}),
  audio_url: Joi.string().uri().allow(null, ""),
  image_url: Joi.string().uri().allow(null, ""),
  order_number: Joi.number().integer().min(1).required(),
  marks: Joi.number().precision(1).min(0).default(1),
  difficulty: Joi.string().valid("easy", "medium", "hard").default("medium"),
  min_words: Joi.number().integer().min(0).default(0),
  max_words: Joi.number().integer().min(0).default(0),
  prep_time_seconds: Joi.number().integer().min(0).default(0),
  record_time_seconds: Joi.number().integer().min(0).default(0),
  tags: Joi.array().items(Joi.string()).default([]),
});

const sectionSchema = Joi.object({
  id: Joi.string().uuid().optional(),
  section_name: Joi.string().max(255).required(),
  section_type: Joi.string().valid("reading", "listening", "writing", "speaking").required(),
  sub_type: Joi.string().max(50).allow(null, ""),
  time_limit_minutes: Joi.number().integer().min(1).required(),
  order_number: Joi.number().integer().min(1).required(),
  instructions: Joi.string().allow(null, ""),
  question_types_allowed: Joi.array().items(Joi.string()).default([]),
  task_count: Joi.number().integer().min(1).default(1),
  questions: Joi.array().items(questionSchema).default([]),
});

export const createTestSchema = Joi.object({
  title: Joi.string().min(3).max(255).trim().required(),
  exam_type: Joi.string().valid("IELTS", "PTE").required(),
  test_category: Joi.string().valid("full_mock", "single_module").required(),
  difficulty_level: Joi.string().valid("easy", "medium", "hard").default("medium"),
  passing_score: Joi.number().precision(1).min(0).max(90).default(6.5),
  min_required_band: Joi.number().precision(1).min(0).max(90).default(6.0),
  total_duration: Joi.number().integer().min(30).required(),
  is_premium: Joi.boolean().default(false),
  is_published: Joi.boolean().default(false),
  sections: Joi.array().items(sectionSchema).min(1).required(),
});

export const nestedTestUpsertSchema = Joi.object({
  test: Joi.object({
    title: Joi.string().min(3).max(255),
    exam_type: Joi.string().valid("IELTS", "PTE"),
    test_category: Joi.string().valid("full_mock", "single_module"),
    total_duration: Joi.number().integer().min(30),
    difficulty_level: Joi.string().valid("easy", "medium", "hard"),
    passing_score: Joi.number().precision(1).min(0).max(90),
    min_required_band: Joi.number().precision(1).min(0).max(90),
    is_published: Joi.boolean(),
    is_premium: Joi.boolean(),
  })
    .min(1)
    .optional(),
  sections: Joi.array().items(sectionSchema).min(1).required(),
});

export const updateHeaderSchema = Joi.object({
  title: Joi.string().min(3).max(255).optional(),
  exam_type: Joi.string().valid("IELTS", "PTE").optional(),
  test_category: Joi.string().valid("full_mock", "single_module").optional(),
  is_published: Joi.boolean().optional(),
  difficulty_level: Joi.string().valid("easy", "medium", "hard").optional(),
  passing_score: Joi.number().precision(1).min(0).max(90).optional(),
  min_required_band: Joi.number().precision(1).min(0).max(90).optional(),
  total_duration: Joi.number().integer().min(30).optional(),
  is_premium: Joi.boolean().optional(),
}).min(1);

export const updateQuestionSchema = Joi.object({
  question_type: Joi.string().max(50).optional(),
  sub_question_type: Joi.string().max(50).allow(null, "").optional(),
  question_text: Joi.string().optional(),
  passage_text: Joi.string().allow(null, "").optional(),
  word_limit_instruction: Joi.string().allow(null, "").optional(),
  options: Joi.alternatives().try(Joi.array(), Joi.object()).optional(),
  correct_answer: Joi.alternatives().try(Joi.object(), Joi.array(), Joi.string(), Joi.number()).optional(),
  content: Joi.object().optional(),
  audio_url: Joi.string().uri().allow(null, "").optional(),
  image_url: Joi.string().uri().allow(null, "").optional(),
  order_number: Joi.number().integer().min(1).optional(),
  marks: Joi.number().precision(1).optional(),
  difficulty: Joi.string().valid("easy", "medium", "hard").optional(),
  min_words: Joi.number().integer().min(0).optional(),
  max_words: Joi.number().integer().min(0).optional(),
  prep_time_seconds: Joi.number().integer().min(0).optional(),
  record_time_seconds: Joi.number().integer().min(0).optional(),
  tags: Joi.array().items(Joi.string()).optional(),
}).min(1);

export const addQuestionSchema = questionSchema.keys({
  section_id: Joi.string().uuid().required(),
});