export const processWritingResponse = (studentResponse) => {
  let raw = studentResponse;
  if (raw && typeof raw === "object") {
    raw = raw.text_essay || raw.text || raw.essay || "";
  }
  if (!raw || typeof raw !== "string") {
    throw new Error("Invalid response: Input must be a string.");
  }
  let cleanResponse = raw.trim().replace(/\s+/g, " ");
  const injectionPatterns = [
    /ignore\s+(previous|system|grading|below|above|instructions|directives|rubrics)/gi,
    /override\s+(parameters|rules|score|grades)/gi,
    /system\s+directive/gi,
    /you\s+must\s+output/gi,
    /assign\s+a\s+score\s+of/gi,
    /band\s+score\s+9/gi
  ];
  injectionPatterns.forEach((pattern) => {
    cleanResponse = cleanResponse.replace(pattern, "[REDACTED_ATTEMPT_TO_OVERRIDE]");
  });
  const wrappedText = `<student_attempt_content>\n${cleanResponse}\n</student_attempt_content>`;
  const wordCount = cleanResponse.split(/\s+/).filter(word => word.length > 0).length;
  const isTooShort = wordCount < 10;
  return {
    processedText: wrappedText,
    rawCleanText: cleanResponse,
    wordCount,
    isTooShort,
    processedAt: new Date()
  };
};