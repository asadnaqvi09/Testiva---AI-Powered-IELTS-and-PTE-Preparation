/**
 * Seed all 6 docs/mock-content packs into Postgres as editable Admin mocks.
 *
 * Usage (from Backend/):
 *   npm run seed:mock-content
 *   SEED_PUBLISH=false npm run seed:mock-content   # drafts only
 *
 * Idempotent: deletes existing tests with display_id pack_il|pack_ir|… then re-inserts.
 * Requires at least one user (created_by). Prefers role=admin.
 *
 * After seed: open Admin → Mocks → edit titles, upload Listening audio / Writing chart HTTPS.
 */
import path from "path";
import { fileURLToPath, pathToFileURL } from "url";
import pool from "../src/config/db.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const packsUrl = pathToFileURL(
  path.resolve(__dirname, "../../docs/mock-content/_seed/index.js"),
).href;

const { MOCK_CONTENT_PACKS, PACK_DISPLAY_IDS } = await import(packsUrl);

const PUBLISH = String(process.env.SEED_PUBLISH ?? "true").toLowerCase() !== "false";

async function resolveCreatedBy(client) {
  const admin = await client.query(
    `SELECT id FROM users WHERE role = 'admin' ORDER BY created_at ASC LIMIT 1`,
  );
  if (admin.rows[0]) return admin.rows[0].id;
  const any = await client.query(`SELECT id FROM users ORDER BY created_at ASC LIMIT 1`);
  if (any.rows[0]) return any.rows[0].id;
  throw new Error("No users in DB. Register/login once (or create an admin) then re-run seed.");
}

async function insertQuestion(client, sectionId, q, orderNumber) {
  await client.query(
    `INSERT INTO questions (
      section_id, question_type, sub_question_type, passage_text, question_text, word_limit_instruction,
      options, correct_answer, content, audio_url, image_url, order_number, marks, difficulty,
      min_words, max_words, prep_time_seconds, record_time_seconds, tags
    ) VALUES (
      $1::uuid,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9::jsonb,$10,$11,$12,$13,$14::public.difficulty_enum,
      $15,$16,$17,$18,$19::jsonb
    )`,
    [
      sectionId,
      q.question_type,
      q.sub_question_type,
      q.passage_text,
      q.question_text,
      q.word_limit_instruction,
      JSON.stringify(q.options ?? []),
      JSON.stringify(q.correct_answer ?? {}),
      JSON.stringify(q.content ?? {}),
      q.audio_url,
      q.image_url,
      orderNumber,
      q.marks ?? 1,
      q.difficulty || "medium",
      q.min_words ?? 0,
      q.max_words ?? 0,
      q.prep_time_seconds ?? 0,
      q.record_time_seconds ?? 0,
      JSON.stringify(q.tags ?? []),
    ],
  );
}

async function seedPack(client, pack, createdBy) {
  const testRes = await client.query(
    `INSERT INTO tests (
      display_id, title, total_duration, exam_type, test_category, difficulty_level,
      passing_score, min_required_band, is_published, is_premium, created_by
    ) VALUES (
      $1,$2,$3,$4::public.test_type_enum,$5::public.test_category_enum,$6::public.difficulty_enum,
      $7,$8,$9,$10,$11::uuid
    ) RETURNING id, display_id, title`,
    [
      pack.display_id,
      pack.title,
      pack.total_duration,
      pack.exam_type,
      pack.test_category,
      pack.difficulty_level || "medium",
      6.5,
      6.0,
      PUBLISH,
      false,
      createdBy,
    ],
  );
  const testId = testRes.rows[0].id;
  let qCount = 0;

  for (const sec of pack.sections) {
    const secRes = await client.query(
      `INSERT INTO test_sections (
        test_id, section_name, section_type, sub_type, time_limit_minutes, order_number,
        instructions, question_types_allowed, task_count
      ) VALUES (
        $1::uuid,$2,$3::public.section_type_enum,$4,$5,$6,$7,$8::jsonb,$9
      ) RETURNING id`,
      [
        testId,
        sec.section_name,
        sec.section_type,
        sec.sub_type,
        sec.time_limit_minutes,
        sec.order_number,
        sec.instructions,
        JSON.stringify(sec.question_types_allowed ?? []),
        sec.task_count ?? 1,
      ],
    );
    const sectionId = secRes.rows[0].id;
    let oi = 1;
    for (const question of sec.questions || []) {
      await insertQuestion(client, sectionId, question, oi++);
      qCount += 1;
    }
  }

  return { ...testRes.rows[0], sections: pack.sections.length, questions: qCount, source: pack.source_md };
}

async function main() {
  const client = await pool.connect();
  try {
    console.log("Mock content seed — packs:", PACK_DISPLAY_IDS.join(", "));
    console.log("is_published:", PUBLISH);

    await client.query("BEGIN");
    const createdBy = await resolveCreatedBy(client);

    const del = await client.query(
      `DELETE FROM tests WHERE display_id = ANY($1::text[]) RETURNING display_id`,
      [PACK_DISPLAY_IDS],
    );
    if (del.rows.length) {
      console.log("Removed previous pack tests:", del.rows.map((r) => r.display_id).join(", "));
    }

    const results = [];
    for (const pack of MOCK_CONTENT_PACKS) {
      const row = await seedPack(client, pack, createdBy);
      results.push(row);
      console.log(
        `✓ ${row.display_id} ← ${row.source} | ${row.title} | ${row.sections} sections / ${row.questions} Qs`,
      );
    }

    await client.query("COMMIT");
    console.log("\nDone. Open Admin → Mocks and edit media (Listening audio / Writing chart).");
    console.log("Flutter will list published packs when SEED_PUBLISH=true.");
    process.exit(0);
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("SEED FAILED:", err.message);
    console.error(err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end().catch(() => {});
  }
}

main();
