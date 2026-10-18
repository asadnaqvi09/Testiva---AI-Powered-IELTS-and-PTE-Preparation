export const speakingPromptTemplate = (
  transcribedText,
  durationSeconds,
  questionText = "",
  cueCard = "",
) =>
  `You are an IELTS/PTE speaking examiner using official band descriptors.
Question the student was asked:
"""${questionText || "(not provided)"}"""
${cueCard ? `Cue card:\n"""${cueCard}"""\n` : ""}
Student transcript (${durationSeconds}s):
"""${transcribedText}"""
Evaluate how well they answered THIS question.
Return strict JSON: {"overall_band_score": number, "fluency_coherence_score": number, "lexical_resource_score": number, "grammatical_range_score": number, "pronunciation_feedback": string, "improvement_tips": string}`;

/** Audio-native speaking evaluation (Gemini multimodal). STT transcript is optional context. */
export const speakingAudioPromptTemplate = (
  questionText = "",
  cueCard = "",
  transcribedText = "",
) =>
  `You are an IELTS/PTE speaking examiner using official band descriptors.
Listen to the attached student audio response.
Question the student was asked:
"""${questionText || "(not provided)"}"""
${cueCard ? `Cue card:\n"""${cueCard}"""\n` : ""}
${transcribedText ? `Optional transcript hint (may be imperfect):\n"""${transcribedText}"""\n` : ""}
Assess fluency/coherence, lexical resource, grammatical range, and pronunciation from the audio.
Return strict JSON: {"overall_band_score": number, "fluency_coherence_score": number, "lexical_resource_score": number, "grammatical_range_score": number, "pronunciation_feedback": string, "improvement_tips": string, "transcribed_text": string}`;
