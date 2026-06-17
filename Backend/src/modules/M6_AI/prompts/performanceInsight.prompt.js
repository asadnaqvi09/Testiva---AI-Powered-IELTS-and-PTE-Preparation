export const buildModuleFocusPrompt = (examType, performance) => {
  const {
    averageBand,
    highestBand,
    sectionScores,
    weakSections,
    weakQuestionTypes,
    sectionAccuracy,
  } = performance;

  const accuracySummary =
    sectionAccuracy.length > 0
      ? sectionAccuracy
          .map((s) => `${s.section_name}: ${s.accuracy ?? 0}% accuracy (${s.total_attempted} attempts)`)
          .join("; ")
      : "No section accuracy data yet";

  return `You are a certified ${examType} study coach for the Testiva exam-prep app.
Analyze the student's performance and recommend which single module they should focus on most to improve their overall band score.

### Student performance
- Exam type: ${examType}
- Average band: ${averageBand}
- Highest band achieved: ${highestBand}
- Section band averages: Reading ${sectionScores.reading}, Listening ${sectionScores.listening}, Writing ${sectionScores.writing}, Speaking ${sectionScores.speaking}
- Weak sections (accuracy below 50%): ${weakSections.length ? weakSections.join(", ") : "none identified"}
- Weak question types: ${weakQuestionTypes.length ? weakQuestionTypes.join(", ") : "none identified"}
- Practice accuracy by section: ${accuracySummary}

### Rules
- Pick exactly ONE focus module: Reading, Writing, Listening, or Speaking
- Prioritize the module with the lowest band average; use accuracy data as a tiebreaker
- If all scores are zero or missing, recommend Writing for IELTS or Speaking for PTE
- "tip" must be under 25 words, actionable, and mention the focus module
- "reason" must be one short sentence referencing their actual scores when available

Return ONLY valid JSON with this exact shape:
{
  "tip": "string",
  "focus_module": "Reading|Writing|Listening|Speaking",
  "reason": "string"
}`;
};

export const buildFeedbackSuggestionPrompt = (examType = "IELTS") =>
  `Generate a JSON object with a single key "suggestion" containing one detailed feedback message (20-30 words) that a student might write to the developers of a ${examType}/PTE preparation app called Testiva.
It should be constructive — praise something useful or suggest a feature (offline mode, speaking simulation, more mock tests, PDF reports, or dark mode).
Return only the JSON object.`;
