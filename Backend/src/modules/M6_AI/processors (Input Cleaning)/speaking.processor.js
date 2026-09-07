import { GEMINI_MODEL_ID } from "../../../config/gemini.js";
import { generateJsonFromMultimodal } from "../utils/gemini.helper.js";

const AUDIO_MIME_BY_EXT = {
  mp3: "audio/mp3",
  mpeg: "audio/mpeg",
  wav: "audio/wav",
  wave: "audio/wav",
  m4a: "audio/mp4",
  mp4: "audio/mp4",
  aac: "audio/aac",
  ogg: "audio/ogg",
  flac: "audio/flac",
  webm: "audio/webm",
};

const guessMimeFromUrl = (audioUrl) => {
  try {
    const pathname = new URL(audioUrl).pathname.toLowerCase();
    const ext = pathname.split(".").pop()?.split("?")[0];
    return (ext && AUDIO_MIME_BY_EXT[ext]) || "audio/mp3";
  } catch {
    return "audio/mp3";
  }
};

const buildTranscriptionPrompt = () =>
  `You are a speech-to-text engine for IELTS/PTE speaking practice.
Transcribe the spoken audio accurately in English.
Return ONLY valid JSON with this shape:
{
  "transcribedText": "full transcript of what the speaker said",
  "durationSeconds": number_or_null,
  "confidence": number_between_0_and_1
}
Rules:
- Preserve natural wording; do not summarize.
- If speech is unclear, keep best-effort words and lower confidence.
- If no speech is detected, set transcribedText to an empty string and confidence to 0.
- durationSeconds: estimate spoken duration in seconds when possible, else null.`;

/**
 * Gemini-only speech-to-text.
 * @param {string} audioUrl Absolute URL to the learner's spoken audio (e.g. Cloudinary).
 * @returns {Promise<{ transcribedText: string, confidence: number, durationSeconds: number|null, model_used: string }>}
 */
export const processAudioToText = async (audioUrl) => {
  if (!audioUrl || typeof audioUrl !== "string") {
    throw new Error("audioUrl is required for Gemini speech-to-text");
  }

  try {
    const response = await fetch(audioUrl);
    if (!response.ok) {
      throw new Error(`Failed to download audio (${response.status})`);
    }

    const arrayBuffer = await response.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    if (!buffer.length) {
      throw new Error("Downloaded audio file is empty");
    }

    const headerMime = response.headers.get("content-type")?.split(";")[0]?.trim();
    const mimeType =
      (headerMime && headerMime.startsWith("audio/") ? headerMime : null) ||
      guessMimeFromUrl(audioUrl);

    const json = await generateJsonFromMultimodal([
      {
        inlineData: {
          mimeType,
          data: buffer.toString("base64"),
        },
      },
      { text: buildTranscriptionPrompt() },
    ]);

    const transcribedText = String(json.transcribedText ?? json.transcript ?? "").trim();
    const confidence = Number(json.confidence);
    const durationRaw = Number(json.durationSeconds);

    return {
      transcribedText,
      confidence: Number.isFinite(confidence) ? Math.min(Math.max(confidence, 0), 1) : 0.5,
      durationSeconds: Number.isFinite(durationRaw) && durationRaw > 0 ? durationRaw : null,
      model_used: GEMINI_MODEL_ID,
    };
  } catch (error) {
    console.error("Gemini Audio STT Error:", error);
    throw new Error(error.message || "Failed to transcribe audio with Gemini");
  }
};
