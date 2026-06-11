import pool from './src/config/db.js';

async function seed() {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const usersRes = await client.query("SELECT id FROM users LIMIT 1");
    if (usersRes.rows.length === 0) {
      console.error("Please register at least one user in the app first!");
      process.exit(1);
    }
    const userId = usersRes.rows[0].id;

    await client.query("DELETE FROM tests WHERE display_id = 'mck001'");

    const testRes = await client.query(
      `INSERT INTO tests (display_id, title, total_duration, exam_type, test_category, difficulty_level, passing_score, min_required_band, is_published, is_premium, created_by)
       VALUES ($1, $2, $3, $4::public.test_type_enum, $5::public.test_category_enum, $6::public.difficulty_enum, $7, $8, $9, $10, $11)
       RETURNING id`,
      ['mck001', 'IELTS Academic Reading Test 1', 20, 'IELTS', 'singular_module', 'medium', 6.5, 6.0, true, false, userId]
    );
    const testId = testRes.rows[0].id;

    const passage = 'The transformation of modern metropolitan landscapes increasingly hinges upon infrastructure adaptations. Decarbonizing structural frameworks, shifting energy sectors to accommodate multi-tiered renewable grids, and deploying micro-transit initiatives remain foundational to sustainable metrics. Observers argue that private integration framework methodologies, such as carbon offsets, dictate capital pacing. However, comprehensive urban development indices require stricter legislative standardization to avoid developmental stagnation across minor geopolitical divisions.';

    const secRes = await client.query(
      `INSERT INTO test_sections (test_id, section_name, section_type, sub_type, time_limit_minutes, order_number, instructions, question_types_allowed, task_count)
       VALUES ($1, $2, $3::public.section_type_enum, $4, $5, $6, $7, $8::jsonb, $9)
       RETURNING id`,
      [testId, 'Reading Passage 1', 'reading', 'academic', 20, 1, passage, JSON.stringify(['MCQ', 'True/False/NG', 'Yes/No/NG', 'Short Answer']), 10]
    );
    const sectionId = secRes.rows[0].id;

    const questions = [
      {
        type: 'MCQ',
        text: 'What percentage of global energy consumption is projected to come from green hydrogen by 2050?',
        options: ['5%', '10%', '12%', '25%'],
        answer: '12%',
      },
      {
        type: 'True/False/NG',
        text: "Singapore's 'City in a Garden' initiative was fully funded by private sector international carbon credits.",
        options: ['True', 'False', 'Not Given'],
        answer: 'False',
      },
      {
        type: 'True/False/NG',
        text: "Copenhagen's cycling infrastructure was fully operational before the turn of the twenty-first century.",
        options: ['True', 'False', 'Not Given'],
        answer: 'Not Given',
      },
      {
        type: 'Yes/No/NG',
        text: 'The writer implies that new green building codes are intentionally restrictive for developing nations.',
        options: ['Yes', 'No', 'Not Given'],
        answer: 'Yes',
      },
      {
        type: 'Short Answer',
        text: 'Match each city or institution (1–3) with the correct description regarding sustainable infrastructure development.',
        options: [],
        answer: 'Copenhagen',
      },
      {
        type: 'Short Answer',
        text: 'According to Professor Whitfield, what is the single greatest obstacle to complete urban grid decarbonization?',
        options: [],
        answer: 'capital pacing',
      },
      {
        type: 'Short Answer',
        text: 'Global EV sales in 2022 represented ____ percent of total passenger automobile market shares worldwide.',
        options: [],
        answer: '12%',
      },
      {
        type: 'Short Answer',
        text: 'The EU has committed to ending new petrol and diesel vehicle sales across member states by the target year ____.',
        options: [],
        answer: '2035',
      },
      {
        type: 'Short Answer',
        text: 'Complete each sentence with the correct environmental policy framework suffix provided in the reference list.',
        options: [],
        answer: 'standardization',
      },
      {
        type: 'MCQ',
        text: 'What does the passage suggest about automated micro-transit systems currently operating within standard grids?',
        options: ['High Maintenance', 'Cost Effective', 'Scalable', 'Unstable'],
        answer: 'Scalable',
      },
    ];

    for (let i = 0; i < questions.length; i++) {
      const q = questions[i];
      await client.query(
        `INSERT INTO questions (
          section_id, question_type, sub_question_type, passage_text, question_text, word_limit_instruction,
          options, correct_answer, content, audio_url, image_url, order_number, marks, difficulty,
          min_words, max_words, prep_time_seconds, record_time_seconds, tags
        ) VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8::jsonb, $9::jsonb, $10, $11, $12, $13, $14::public.difficulty_enum, $15, $16, $17, $18, $19::jsonb)`,
        [
          sectionId,
          q.type,
          q.type,
          passage,
          q.text,
          'Choose one option or type response',
          JSON.stringify(q.options),
          JSON.stringify({ answer: q.answer }),
          JSON.stringify({}),
          null,
          null,
          i + 1,
          1,
          'medium',
          0,
          0,
          0,
          0,
          JSON.stringify(['IELTS', 'Reading'])
        ]
      );
    }

    await client.query("COMMIT");
    console.log("SUCCESSFULLY SEEDED IELTS MOCK TEST!");
    process.exit(0);
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("SEEDING ERROR:", err);
    process.exit(1);
  } finally {
    client.release();
  }
}

seed();
