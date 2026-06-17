import pool from "../../../config/db.js";
import cloudinary from "../../../config/cloudinary.js";
import { cacheGetJson, cacheSetJson, cacheDelMany, cacheDelByPrefix } from "../../../utils/redisCache.js";
import * as testModel from "../models/test.model.js";
import {
  createTestSchema,
  nestedTestUpsertSchema,
  updateHeaderSchema,
  updateQuestionSchema,
  addQuestionSchema,
} from "../validator/test.validator.js";

function pteSingleGuard(exam_type, test_category) {
  return exam_type === "PTE" && test_category === "singular_module";
}

function extractCloudinaryPublicId(url) {
  if (!url) return null;
  try {
    const matches = url.match(/\/v\d+\/(testiva\/tests\/[^.]+)/);
    if (matches && matches[1]) return matches[1];
    const parts = url.split("/");
    const filename = parts.pop().split(".")[0];
    const uploadIdx = parts.indexOf("upload");
    if (uploadIdx >= 0) {
      const folder = parts.slice(uploadIdx + 2).join("/");
      return folder ? `${folder}/${filename}` : filename;
    }
    return filename;
  } catch (e) {
    console.error("Error parsing Cloudinary URL:", e);
    return null;
  }
}

function sanitizeQuestionPayload(q) {
  const aiTypes = ["writing", "speaking"];
  const isAi =
    aiTypes.includes((q.question_type || "").toLowerCase()) ||
    aiTypes.includes((q.sub_question_type || "").toLowerCase());
  if (isAi) {
    return { ...q, correct_answer: null };
  }
  return q;
}

async function bustTestCache(id) {
  await cacheDelMany([
    `test:admin:${id}`, 
    `test:runtime:${id}:free`, 
    `test:runtime:${id}:basic`, 
    `test:runtime:${id}:premium`,
    `test:preview:${id}`
  ]);
  await cacheDelByPrefix("test:dash:");
  await cacheDelByPrefix("test:mobile:");
}

export const fetchAdminMocksDashboard = async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 100);
    const offset = (page - 1) * limit;
    const search = req.query.search?.trim() || null;
    const exam_type = req.query.exam_type || "All";
    const cacheKey = `test:dash:${exam_type}:${page}:${limit}:${search || ""}`;
    const cached = await cacheGetJson(cacheKey);
    if (cached) return res.status(200).json({ success: true, cached: true, ...cached });
    const rows = await testModel.listAdminMocksDashboard({ search, exam_type, limit, offset });
    const body = { page, limit, count: rows.length, data: rows };
    await cacheSetJson(cacheKey, body, 45);
    res.status(200).json({ success: true, cached: false, ...body });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message || "Error fetching mocks" });
  }
};

export const fetchMobileMocksDashboard = async (req, res) => {
  try {
    const subscription = req.user.subscription || "free";
    const userPreference = req.user.preference;
    const role = req.user.role;
    
    let examTypes = ["IELTS", "PTE"];
    const filter = req.query.exam_type;

    // Enforce isolation for non-premium/non-admin users
    if (role !== "admin" && subscription !== "premium") {
      if (!userPreference) {
        return res.status(403).json({ success: false, message: "Please select your learning preference to continue" });
      }
      examTypes = [userPreference];
    } else {
      if (filter === "IELTS") examTypes = ["IELTS"];
      else if (filter === "PTE") examTypes = ["PTE"];
    }

    const cacheKey = `test:mobile:${req.user.id}:${filter || "ALL"}:${subscription}`;
    const cached = await cacheGetJson(cacheKey);
    if (cached) return res.status(200).json({ success: true, cached: true, data: cached });
    
    const rows = await testModel.listMobilePublished(req.user.id, examTypes);
    const data = rows.map((r) => ({
      id: r.id,
      display_id: r.display_id,
      title: r.title,
      exam_type: r.exam_type,
      test_category: r.test_category,
      difficulty_level: r.difficulty_level,
      total_duration: r.total_duration,
      min_required_band: r.min_required_band,
      total_questions: r.total_questions,
      sub_question_type_indicators: r.sub_question_types || [],
      last_attempt: r.last_attempt_id
        ? {
            attempt_id: r.last_attempt_id,
            overall_band_score: r.last_attempt_score,
            status: r.last_attempt_status,
          }
        : null,
      cta: r.last_attempt_id ? "retake" : "start",
    }));
    await cacheSetJson(cacheKey, data, 30);
    res.status(200).json({ success: true, cached: false, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message || "Error fetching mobile mocks" });
  }
};

export const getTestPreview = async (req, res) => {
  try {
    const { id } = req.params;
    const cacheKey = `test:preview:${id}`;
    const cached = await cacheGetJson(cacheKey);
    if (cached) {
      // Validate track access on cache hit
      if (req.user.role !== "admin" && req.user.subscription !== "premium") {
        if (cached.exam_type !== req.user.preference) {
          return res.status(403).json({ success: false, message: "Access denied. Track is locked to your selected preference." });
        }
      }
      return res.status(200).json({ success: true, data: cached });
    }

    const t = await testModel.getPreviewPayload(id);
    if (!t) return res.status(404).json({ success: false, message: "Test not found" });
    
    if (req.user.role !== "admin") {
      if (!t.is_published) {
        return res.status(403).json({ success: false, message: "Not available" });
      }
      // Track isolation validation logic
      if (req.user.subscription !== "premium" && t.exam_type !== req.user.preference) {
        return res.status(403).json({ success: false, message: "Access denied. Track is locked to your selected preference." });
      }
    }

    await cacheSetJson(cacheKey, t, 60);
    res.status(200).json({ success: true, data: t });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message || "Error" });
  }
};

export const getTestRuntime = async (req, res) => {
  try {
    const { id } = req.params;
    const subscription = req.user.subscription || "free";
    const adminReview = req.user.role === "admin" && req.query.admin_review === "true";
    const cacheKey = adminReview ? `test:admin:${id}` : `test:runtime:${id}:${subscription}`;
    
    const cached = await cacheGetJson(cacheKey);
    if (cached) {
      if (!adminReview && subscription !== "premium") {
        if (cached.exam_type !== req.user.preference) {
          return res.status(403).json({ success: false, message: "Access denied. Track is locked to your selected preference." });
        }
      }
      return res.status(200).json({ success: true, data: cached });
    }

    const data = await testModel.getStructuredTest(id, { includeCorrect: adminReview });
    if (!data) return res.status(404).json({ success: false, message: "Test not found" });
    
    if (req.user.role !== "admin") {
      if (!data.is_published) return res.status(403).json({ success: false, message: "Not available" });
      
      // Track isolation validation logic
      if (subscription !== "premium" && data.exam_type !== req.user.preference) {
        return res.status(403).json({ success: false, message: "Access denied. Track is locked to your selected preference." });
      }

      if (subscription === "free") {
        const allowed = ["reading", "writing"];
        data.sections = data.sections.filter((s) => allowed.includes(s.section_type?.toLowerCase()));
      }
    }

    await cacheSetJson(cacheKey, data, 60);
    res.status(200).json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message || "Error" });
  }
};

export const uploadTestAsset = async (req, res) => {
  try {
    if (!req.file?.buffer) {
      return res.status(400).json({ success: false, message: "file required" });
    }
    const isAudio = req.file.mimetype.startsWith("audio");
    const folder = "testiva/tests";
    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder,
          resource_type: isAudio ? "video" : "image",
          use_filename: true,
        },
        (err, r) => (err ? reject(err) : resolve(r)),
      );
      stream.end(req.file.buffer);
    });
    res.status(201).json({ success: true, data: { url: result.secure_url, public_id: result.public_id } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message || "Upload failed" });
  }
};

export const createFullTest = async (req, res) => {
  const client = await pool.connect();
  try {
    const { error, value } = createTestSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    
    if (pteSingleGuard(value.exam_type, value.test_category)) {
      return res.status(400).json({ success: false, message: "PTE must use full_mock" });
    }
    if (value.test_category === "singular_module" && value.sections.length === 0) {
      return res.status(400).json({ success: false, message: "singular_module requires exactly one section" });
    }
    if (value.test_category === "full_mock") {
      const err = await testModel.validateFullMockSections(value.sections);
      if (err) return res.status(400).json({ success: false, message: err });
    }
    await client.query("BEGIN");
    if (value.test_category === "singular_module") {
      const st = value.sections[0].section_type;
      const conflict = await testModel.findSingleModuleConflict(value.exam_type, st, null, client);
      if (conflict) {
        await client.query("ROLLBACK");
        return res.status(409).json({
          success: false,
          message: `singular_module already exists for ${value.exam_type} ${st}`,
        });
      }
    }
    const display_id = await testModel.allocDisplayId(client);
    const newTest = await testModel.createTest(
      {
        display_id,
        title: value.title,
        exam_type: value.exam_type,
        test_category: value.test_category,
        total_duration: value.total_duration,
        created_by: req.user.id,
        difficulty_level: value.difficulty_level,
        passing_score: value.passing_score,
        min_required_band: value.min_required_band,
        is_premium: value.is_premium,
        is_published: value.is_published,
      },
      client,
    );
    for (const section of value.sections) {
      const newSection = await testModel.createSection(
        {
          test_id: newTest.id,
          section_name: section.section_name,
          section_type: section.section_type,
          sub_type: section.sub_type,
          time_limit_minutes: section.time_limit_minutes,
          order_number: section.order_number,
          instructions: section.instructions,
          question_types_allowed: section.question_types_allowed,
          task_count: section.task_count,
        },
        client,
      );
      for (const q of section.questions || []) {
        await testModel.createSingleQuestion({ ...sanitizeQuestionPayload(q), section_id: newSection.id }, client);
      }
    }
    await client.query("COMMIT");
    await bustTestCache(newTest.id);
    res.status(201).json({ success: true, data: { id: newTest.id, display_id, title: value.title } });
  } catch (e) {
    await client.query("ROLLBACK");
    console.log("Error in Create Test : ", e.message);
    res.status(500).json({ success: false, message: e.message });
  } finally {
    client.release();
  }
};

export const upsertTestNested = async (req, res) => {
  const client = await pool.connect();
  try {
    const { error, value } = nestedTestUpsertSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    const testId = req.params.id;
    const head = await client.query(`SELECT * FROM tests WHERE id = $1::uuid`, [testId]);
    if (!head.rows[0]) return res.status(404).json({ success: false, message: "Test not found" });
    const mergedExam = value.test?.exam_type || head.rows[0].exam_type;
    const mergedCat = value.test?.test_category || head.rows[0].test_category;
    if (pteSingleGuard(mergedExam, mergedCat)) {
      return res.status(400).json({ success: false, message: "PTE must use full_mock" });
    }
    if (mergedCat === "singular_module" && value.sections.length === 0) {
      return res.status(400).json({ success: false, message: "singular_module requires exactly one section" });
    }
    if (mergedCat === "full_mock") {
      const err = await testModel.validateFullMockSections(value.sections);
      if (err) return res.status(400).json({ success: false, message: err });
    }
    await client.query("BEGIN");
    if (mergedCat === "singular_module") {
      const st = value.sections[0].section_type;
      const conflict = await testModel.findSingleModuleConflict(mergedExam, st, testId, client);
      if (conflict) {
        await client.query("ROLLBACK");
        return res.status(409).json({
          success: false,
          message: `singular_module already exists for ${mergedExam} ${st}`,
        });
      }
    }
    if (value.test && Object.keys(value.test).length) {
      await testModel.updateTestHeader(testId, value.test, client);
    }
    const sectionKeep = [];
    for (const s of value.sections) {
      let sid = s.id;
      if (sid) {
        await testModel.updateSection(
          sid,
          {
            section_name: s.section_name,
            section_type: s.section_type,
            sub_type: s.sub_type,
            time_limit_minutes: s.time_limit_minutes,
            order_number: s.order_number,
            instructions: s.instructions,
            question_types_allowed: s.question_types_allowed,
            task_count: s.task_count,
          },
          client,
         );
      } else {
        const row = await testModel.createSection(
          {
            test_id: testId,
            section_name: s.section_name,
            section_type: s.section_type,
            sub_type: s.sub_type,
            time_limit_minutes: s.time_limit_minutes,
            order_number: s.order_number,
            instructions: s.instructions,
            question_types_allowed: s.question_types_allowed,
            task_count: s.task_count,
          },
          client,
        );
        sid = row.id;
      }
      sectionKeep.push(sid);
      const qKeep = [];
      for (const q of s.questions || []) {
        const { id: qid, ...rest } = q;
        if (qid) {
          await testModel.updateQuestion(qid, sanitizeQuestionPayload(rest), client);
          qKeep.push(qid);
        } else {
          const row = await testModel.createSingleQuestion({ ...sanitizeQuestionPayload(rest), section_id: sid }, client);
          qKeep.push(row.id);
        }
      }
      await testModel.deleteQuestionsNotIn(sid, qKeep, client);
    }
    await testModel.deleteSectionsNotIn(testId, sectionKeep, client);
    await client.query("COMMIT");
    await bustTestCache(testId);
    const full = await testModel.getFullTestDetails(testId);
    res.status(200).json({ success: true, data: full });
  } catch (e) {
    await client.query("ROLLBACK");
    console.log("Error in Update Nested Test : ", e.message);
    res.status(500).json({ success: false, message: e.message });
  } finally {
    client.release();
  }
};

export const fetchAvailableTests = async (req, res) => {
  try {
    const { subscription, role, preference } = req.user;
    if (role === "admin") {
      const tests = await testModel.getAllTests(100, 0);
      return res.status(200).json({ success: true, data: tests });
    }
    
    let examTypes = ["IELTS"];
    let allowedSections = null;
    
    if (subscription === "free") {
      allowedSections = ["Reading", "Writing"];
      examTypes = [preference || "IELTS"];
    } else if (subscription === "basic") {
      examTypes = [preference || "IELTS"];
    } else if (subscription === "premium") {
      examTypes = ["IELTS", "PTE"];
    }
    
    const tests = await testModel.getTestsByFilters(examTypes, allowedSections);
    res.status(200).json({ success: true, data: tests });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching available tests" });
  }
};

export const fetchTests = async (req, res) => {
  return fetchAdminMocksDashboard(req, res);
};

export const getTestById = async (req, res) => {
  try {
    const subscription = req.user.subscription || "free";
    const cacheKey = req.user.role === "admin" ? `test:admin:${req.params.id}` : `test:runtime:${req.params.id}:${subscription}`;
    const cached = await cacheGetJson(cacheKey);
    if (cached) {
      if (req.user.role !== "admin" && subscription !== "premium") {
        if (cached.exam_type !== req.user.preference) {
          return res.status(403).json({ success: false, message: "Access denied. Track is locked to your selected preference." });
        }
      }
      return res.status(200).json({ success: true, data: cached });
    }
    
    const includeCorrect = req.user.role === "admin";
    let testDetails = await testModel.getStructuredTest(req.params.id, { includeCorrect });
    if (!testDetails) return res.status(404).json({ success: false, message: "Test not found" });
    
    if (req.user.role !== "admin") {
      if (!testDetails.is_published) return res.status(403).json({ success: false, message: "Not available" });
      if (subscription !== "premium" && testDetails.exam_type !== req.user.preference) {
        return res.status(403).json({ success: false, message: "Access denied. Track is locked to your selected preference." });
      }
      if (subscription === "free") {
        const allowedSections = ["reading", "writing"];
        testDetails.sections = testDetails.sections.filter((s) => allowedSections.includes(s.section_type?.toLowerCase()));
      }
    }
    await cacheSetJson(cacheKey, testDetails, 60);
    res.status(200).json({ success: true, data: testDetails });
  } catch (error) {
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const updateTestHeaderByID = async (req, res) => {
  try {
    const { error, value } = updateHeaderSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    const testId = req.params.id;
    const current = await pool.query(`SELECT exam_type, test_category FROM tests WHERE id = $1::uuid`, [testId]);
    if (!current.rows[0]) return res.status(404).json({ success: false, message: "Test not found" });
    const mergedExam = value.exam_type || current.rows[0].exam_type;
    const mergedCat = value.test_category || current.rows[0].test_category;
    if (pteSingleGuard(mergedExam, mergedCat)) {
      return res.status(400).json({ success: false, message: "PTE must use full_mock" });
    }
    if (mergedCat === "singular_module" && (value.exam_type || value.test_category)) {
      const sectionsCheck = await pool.query(`SELECT section_type FROM test_sections WHERE test_id = $1::uuid`, [testId]);
      if (sectionsCheck.rows.length > 0) {
        const st = sectionsCheck.rows[0].section_type;
        const conflict = await testModel.findSingleModuleConflict(mergedExam, st, testId);
        if (conflict) {
          return res.status(409).json({
            success: false,
            message: `Conflict detected: singular_module configuration already exists for ${mergedExam} ${st}`,
          });
        }
      }
    }
    const updatedTest = await testModel.updateTestHeader(testId, value);
    await bustTestCache(testId);
    res.status(200).json({ success: true, data: updatedTest });
  } catch (error) {
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const updateTestQuestionByID = async (req, res) => {
  try {
    const { error, value } = updateQuestionSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    const updatedQuestion = await testModel.updateQuestion(req.params.id, value);
    if (!updatedQuestion) return res.status(404).json({ success: false, message: "Question not found" });
    const sec = await pool.query(`SELECT test_id FROM test_sections WHERE id = $1::uuid`, [updatedQuestion.section_id]);
    if (sec.rows[0]?.test_id) await bustTestCache(sec.rows[0].test_id);
    res.status(200).json({ success: true, data: updatedQuestion });
  } catch (error) {
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const addQuestionToSection = async (req, res) => {
  try {
    const { error, value } = addQuestionSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    const { id: _unusedId, ...payload } = value;
    const newQuestion = await testModel.createSingleQuestion(payload);
    const sec = await pool.query(`SELECT test_id FROM test_sections WHERE id = $1::uuid`, [value.section_id]);
    if (sec.rows[0]?.test_id) await bustTestCache(sec.rows[0].test_id); 
    res.status(201).json({ success: true, data: newQuestion });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error adding question: " + error.message });
  }
};

export const deleteQuestionFromSection = async (req, res) => {
  try {
    const { id } = req.params;
    const question = await testModel.getQuestionById(id);
    if (!question) return res.status(404).json({ success: false, message: "Question not found" });
    const sec = await pool.query(`SELECT test_id FROM test_sections WHERE id = $1::uuid`, [question.section_id]);
    const publicId = extractCloudinaryPublicId(question.audio_url);
    if (publicId) {
      try {
        await cloudinary.uploader.destroy(publicId, { resource_type: "video" });
      } catch (cloudErr) {
        console.error("Cloudinary delete failed:", cloudErr);
      }
    }
    await testModel.deleteQuestion(id);
    if (sec.rows[0]?.test_id) await bustTestCache(sec.rows[0].test_id);
    res.status(200).json({ success: true, message: "Question deleted successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const deleteTest = async (req, res) => {
  try {
    const testId = req.params.id;
    const testDetails = await testModel.getFullTestDetails(testId);
    if (!testDetails) return res.status(404).json({ success: false, message: "Test not found" });
    for (const s of testDetails.sections) {
      for (const q of s.questions) {
        const publicId = extractCloudinaryPublicId(q.audio_url);
        if (publicId) {
          try {
            await cloudinary.uploader.destroy(publicId, { resource_type: "video" });
          } catch (e) {
            /* ignore cloud errors to prevent block execution */
          }
        }
      }
    }
    await testModel.deleteTest(testId);
    await bustTestCache(testId);
    res.status(200).json({ success: true, message: "Test deleted successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};