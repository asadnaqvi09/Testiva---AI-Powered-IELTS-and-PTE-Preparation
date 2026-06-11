export const speakingPromptTemplate = (transcribedText, durationSeconds) =>
  `You are an IELTS speaking examiner. Transcript (${durationSeconds}s): """${transcribedText}"""
Return strict JSON: {"overall_band_score": number, "fluency_coherence_score": number, "lexical_resource_score": number, "grammatical_range_score": number, "pronunciation_feedback": string, "improvement_tips": string}`;