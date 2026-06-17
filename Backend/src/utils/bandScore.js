const AI_SECTIONS = new Set(["writing", "speaking"]);

export function roundIeltsBand(band) {
  return Math.round(Math.min(9, Math.max(0, band)) * 2) / 2;
}

export function roundPteBand(band) {
  return Math.round(Math.min(9, Math.max(0, band)));
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
