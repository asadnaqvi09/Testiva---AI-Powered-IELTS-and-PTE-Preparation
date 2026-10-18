/** Objective MCQ / T-F / matching / fill-blank compare. No AI. */

const CHOICE_TYPES = new Set([
  "mcq",
  "true_false",
  "yes_no",
  "tf_not_given",
  "yn_not_given",
]);

const MULTI_TYPES = new Set(["multi_select"]);

const MATCH_TYPES = new Set(["matching", "match_the_column"]);

const FILL_TYPES = new Set([
  "fill_blank",
  "short_answer",
  "sentence_completion",
  "form_fill",
]);

export const normalizeAnswer = (v) => {
  if (v === null || v === undefined) return "";
  if (typeof v === "string") return v.trim().toLowerCase().replace(/\s+/g, " ");
  if (Array.isArray(v)) return v.map((x) => normalizeAnswer(x)).filter(Boolean).sort().join("\0");
  if (typeof v === "object") {
    if (v.text_essay != null) return normalizeAnswer(v.text_essay);
    if (v.answer != null) return normalizeAnswer(v.answer);
    if (v.selected != null) return normalizeAnswer(v.selected);
    if (v.value != null && v.key != null) return `${normalizeAnswer(v.key)}=${normalizeAnswer(v.value)}`;
    return JSON.stringify(v);
  }
  return String(v).trim().toLowerCase();
};

const unwrap = (userAnswer) => {
  if (userAnswer && typeof userAnswer === "object" && !Array.isArray(userAnswer)) {
    if (userAnswer.text_essay != null) return userAnswer.text_essay;
    if (userAnswer.selected != null) return userAnswer.selected;
    if (userAnswer.answer != null && !userAnswer.key) return userAnswer.answer;
  }
  return userAnswer;
};

const toMatchingMap = (value) => {
  if (!Array.isArray(value)) return null;
  const map = {};
  for (const item of value) {
    if (!item || typeof item !== "object") continue;
    map[normalizeAnswer(item.key)] = normalizeAnswer(item.value);
  }
  return map;
};

const matchingEqual = (user, correct) => {
  const a = toMatchingMap(user);
  const b = toMatchingMap(correct);
  if (a && b) {
    const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
    if (!keys.size) return false;
    for (const k of keys) {
      if (a[k] !== b[k]) return false;
    }
    return true;
  }
  return normalizeAnswer(user) === normalizeAnswer(correct);
};

const multiSelectEqual = (user, correct) => {
  const toList = (v) => {
    if (Array.isArray(v)) return v.map((x) => normalizeAnswer(x)).filter(Boolean).sort();
    if (typeof v === "string") {
      return v
        .split(/[,|]/)
        .map((x) => normalizeAnswer(x))
        .filter(Boolean)
        .sort();
    }
    const one = normalizeAnswer(v);
    return one ? [one] : [];
  };
  const a = toList(user).join("\0");
  const b = toList(correct).join("\0");
  return a.length > 0 && a === b;
};

const fillEqual = (user, correct) => {
  const raw = unwrap(user);
  const acceptable = Array.isArray(correct)
    ? correct.map((a) => normalizeAnswer(typeof a === "object" && a?.value != null ? a.value : a))
    : String(correct ?? "")
        .split(/[|/]/)
        .map((a) => normalizeAnswer(a));
  const cleaned = acceptable.filter(Boolean);
  if (!cleaned.length) return false;
  return cleaned.includes(normalizeAnswer(raw));
};

/**
 * Grade one objective question against stored correct_answer.
 * @returns {{ is_correct: boolean, marks_obtained: number }}
 */
export const scoreObjectiveQuestion = (question, userAnswer) => {
  const marks = Number(question.marks) || 0;
  const qType = (question.question_type || "").toLowerCase();
  const sub = (question.sub_question_type || "").toLowerCase();
  const type = CHOICE_TYPES.has(qType) || CHOICE_TYPES.has(sub) ? "choice"
    : MULTI_TYPES.has(qType) || MULTI_TYPES.has(sub) ? "multi"
    : MATCH_TYPES.has(qType) || MATCH_TYPES.has(sub) ? "match"
    : FILL_TYPES.has(qType) || FILL_TYPES.has(sub) ? "fill"
    : "choice";

  const correct = question.correct_answer;
  const answer = unwrap(userAnswer);
  let ok = false;
  if (type === "multi") ok = multiSelectEqual(answer, correct);
  else if (type === "match") ok = matchingEqual(answer, correct);
  else if (type === "fill") ok = fillEqual(answer, correct);
  else ok = normalizeAnswer(answer) === normalizeAnswer(correct) && normalizeAnswer(answer) !== "";

  return { is_correct: ok, marks_obtained: ok ? marks : 0 };
};

export const tallyObjective = (responses) => {
  const gradable = (responses || []).filter((r) => r.is_correct !== null && r.is_correct !== undefined);
  const correct = gradable.filter((r) => r.is_correct === true || r.is_correct === "true").length;
  return { correct, total: gradable.length };
};
