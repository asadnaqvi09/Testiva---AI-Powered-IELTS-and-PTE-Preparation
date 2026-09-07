import { model } from "../../../config/gemini.js";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const isRetryableGeminiError = (err) => {
  const message = String(err?.message || err || "");
  return (
    message.includes("503") ||
    message.includes("429") ||
    message.includes("high demand") ||
    message.includes("JSON") ||
    message.includes("Unterminated string")
  );
};

export const parseGeminiJson = (rawText) => {
  const clean = rawText.replace(/```json|```/gi, "").trim();
  try {
    return JSON.parse(clean);
  } catch {
    const start = clean.indexOf("{");
    const end = clean.lastIndexOf("}");
    if (start >= 0 && end > start) {
      return JSON.parse(clean.slice(start, end + 1));
    }
    throw new Error("Failed to parse Gemini JSON response");
  }
};

const runGeminiWithRetry = async (content, maxAttempts = 3) => {
  let lastError;
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const result = await model.generateContent(content);
      const text = (await result.response).text().trim();
      return parseGeminiJson(text);
    } catch (err) {
      lastError = err;
      if (isRetryableGeminiError(err) && attempt < maxAttempts) {
        await sleep(1000 * attempt);
        continue;
      }
      throw err;
    }
  }
  throw lastError;
};

export const generateJsonFromPrompt = async (prompt, maxAttempts = 3) =>
  runGeminiWithRetry(prompt, maxAttempts);

/**
 * Multimodal Gemini call (text + inline audio/image parts).
 * @param {Array<string|{text?:string,inlineData?:{mimeType:string,data:string}}>} parts
 */
export const generateJsonFromMultimodal = async (parts, maxAttempts = 3) =>
  runGeminiWithRetry(parts, maxAttempts);
