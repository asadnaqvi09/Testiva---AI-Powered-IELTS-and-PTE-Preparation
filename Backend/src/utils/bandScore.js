const AI_SECTIONS = new Set(["writing", "speaking"]);

export function roundIeltsBand(band) {
  return Math.round(Math.min(9, Math.max(0, band)) * 2) / 2;
}

export function roundPteBand(band) {
  return Math.round(Math.min(9, Math.max(0, band)));
}

const READING_MIN_CORRECT = [
  [39, 9], [37, 8.5], [35, 8], [33, 7.5], [30, 7], [27, 6.5], [23, 6],
  [19, 5.5], [15, 5], [13, 4.5], [10, 4], [8, 3.5], [6, 3], [4, 2.5],
  [3, 2], [2, 1.5], [1, 1], [0, 0],
];

const LISTENING_MIN_CORRECT = [
  [39, 9], [37, 8.5], [35, 8], [32, 7.5], [30, 7], [26, 6.5], [23, 6],
  [18, 5.5], [16, 5], [13, 4.5], [11, 4], [8, 3.5], [6, 3], [4, 2.5],
  [3, 2], [2, 1.5], [1, 1], [0, 0],
];

function lookupBand(scaledOutOf40, table) {
  const n = Math.max(0, Math.min(40, Math.round(scaledOutOf40)));
  for (const [minCorrect, band] of table) {
    if (n >= minCorrect) return band;
  }
  return 0;
}

function scaleTo40Band(correct, total, table, examType) {
  if (!total || total <= 0) return 0;
  const ielts = lookupBand((Number(correct) / Number(total)) * 40, table);
  return (examType || "").toUpperCase() === "PTE" ? roundPteBand(ielts) : roundIeltsBand(ielts);
}

export function bandFromReadingCorrect(correct, total, examType = "IELTS") {
  return scaleTo40Band(correct, total, READING_MIN_CORRECT, examType);
}

export function bandFromListeningCorrect(correct, total, examType = "IELTS") {
  return scaleTo40Band(correct, total, LISTENING_MIN_CORRECT, examType);
}

export function accuracyToBand(correct, total, examType = "IELTS") {
  if (total <= 0) return 0;
  const ratio = correct / total;
  const raw = ratio * 9;
  return (examType || "").toUpperCase() === "PTE" ? roundPteBand(raw) : roundIeltsBand(raw);
}

function objectiveSectionBand(responses, examType) {
  const gradable = responses.filter((r) => r.is_correct !== null);
  if (!gradable.length) return null;
  const correct = gradable.filter((r) => r.is_correct).length;
  const section = (responses[0]?.section_type || "").toLowerCase();
  if (section === "listening") return bandFromListeningCorrect(correct, gradable.length, examType);
  if (section === "reading") return bandFromReadingCorrect(correct, gradable.length, examType);
  return accuracyToBand(correct, gradable.length, examType);
}

function sectionHasAiPending(responses) {
  return responses.some((r) => r.is_correct === null);
}

/**
 * Derive module band scores from graded user_responses rows.
 * Each row should include: is_correct, marks_obtained, total_marks, section_type.
 */
export function computeAttemptBandScores(responses, { examType = "IELTS", testCategory = "full_mock" } = {}) {
  const bySection = { reading: [], listening: [], writing: [], speaking: [] };
  for (const r of responses) {
    const key = (r.section_type || "").toLowerCase();
    if (bySection[key]) bySection[key].push(r);
  }

  const reading = bySection.reading.length ? objectiveSectionBand(bySection.reading, examType) : null;
  const listening = bySection.listening.length ? objectiveSectionBand(bySection.listening, examType) : null;

  const writingPending = bySection.writing.length > 0 && sectionHasAiPending(bySection.writing);
  const speakingPending = bySection.speaking.length > 0 && sectionHasAiPending(bySection.speaking);

  const readingScore = reading ?? 0;
  const listeningScore = listening ?? 0;
  const writingScore = 0;
  const speakingScore = 0;

  let overallBand = 0;
  const isPte = (examType || "").toUpperCase() === "PTE";
  const roundOverall = (v) => (isPte ? roundPteBand(v) : roundIeltsBand(v));

  if (testCategory === "singular_module") {
    const active = ["reading", "listening", "writing", "speaking"].find((k) => bySection[k].length > 0);
    if (active && !AI_SECTIONS.has(active)) {
      overallBand = objectiveSectionBand(bySection[active], examType) ?? 0;
    } else if (active && AI_SECTIONS.has(active)) {
      overallBand = 0;
    }
  } else {
    const objectiveParts = [];
    if (bySection.reading.length && reading !== null) objectiveParts.push(reading);
    if (bySection.listening.length && listening !== null) objectiveParts.push(listening);
    if (objectiveParts.length) {
      overallBand = roundOverall(objectiveParts.reduce((a, b) => a + b, 0) / objectiveParts.length);
    }
    if ((writingPending || speakingPending) && objectiveParts.length === 0) {
      overallBand = 0;
    }
  }

  return {
    reading_score: readingScore,
    listening_score: listeningScore,
    writing_score: writingScore,
    speaking_score: speakingScore,
    overall_band_score: overallBand,
    writing_pending: writingPending,
    speaking_pending: speakingPending,
  };
}

export function sumMarks(responses) {
  const gradable = responses.filter((r) => r.is_correct !== null);
  const obtained = gradable.reduce((s, r) => s + (Number(r.marks_obtained) || 0), 0);
  const possible = gradable.reduce((s, r) => s + (Number(r.total_marks) || 0), 0);
  return { marks_obtained: obtained, total_marks: possible };
}

const WRITING_TASK1_SUBS = new Set([
  "task_1",
  "chart_description",
  "request_information",
  "explain_situation",
]);
const WRITING_TASK2_SUBS = new Set([
  "task_2",
  "opinion",
  "discussion",
  "problem_solution",
  "advantages_disadvantages",
  "two_part_question",
  "provide_opinion",
]);

/** Classify IELTS Writing task role from sub_question_type (order fallback for 2 tasks). */
export function classifyWritingTask(subQuestionType, index = 0, total = 1) {
  const sub = String(subQuestionType || "").toLowerCase();
  if (
    WRITING_TASK1_SUBS.has(sub) ||
    sub.includes("task_1") ||
    sub.includes("task1")
  ) {
    return "task1";
  }
  if (
    WRITING_TASK2_SUBS.has(sub) ||
    sub.includes("task_2") ||
    sub.includes("task2")
  ) {
    return "task2";
  }
  if (total === 2) return index === 0 ? "task1" : "task2";
  return "other";
}

/**
 * Aggregate multi-task writing bands.
 * IELTS with Task1+Task2: (T1×1/3)+(T2×2/3). PTE / other: simple average.
 * @param {Array<{ band: number, sub_question_type?: string }>} scoredItems
 */
export function aggregateWritingBand(scoredItems, examType = "IELTS") {
  const items = (scoredItems || []).filter((s) => Number(s?.band) > 0);
  if (!items.length) return 0;
  const isPte = String(examType || "").toUpperCase() === "PTE";
  const mean = items.reduce((a, s) => a + Number(s.band), 0) / items.length;
  if (isPte) return roundPteBand(mean);

  if (items.length === 2) {
    const classified = items.map((s, i) => ({
      band: Number(s.band),
      role: classifyWritingTask(s.sub_question_type, i, 2),
    }));
    const t1 = classified.find((c) => c.role === "task1");
    const t2 = classified.find((c) => c.role === "task2");
    if (t1 && t2) {
      return roundIeltsBand(t1.band * (1 / 3) + t2.band * (2 / 3));
    }
  }
  return roundIeltsBand(mean);
}

/** Map overall/section band (0–9 style) to a CEFR label. */
export function bandToCefr(band, examType = "IELTS") {
  const b = Number(band) || 0;
  void examType;
  if (b >= 8.5) return "C2";
  if (b >= 7.0) return "C1";
  if (b >= 5.5) return "B2";
  if (b >= 4.0) return "B1";
  if (b >= 2.0) return "A2";
  return "A1";
}
