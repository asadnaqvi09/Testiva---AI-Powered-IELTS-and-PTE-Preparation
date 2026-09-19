import { model } from "../../../config/gemini.js";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// clean and optimized code — map SDK errors to missing-key messaging
const normalizeGeminiError = (err) => {
  const message = String(err?.message || err || "");
  if (
    !process.env.GEMINI_API_KEY ||
    /API[_ ]?KEY|api key|PERMISSION_DENIED|UNAUTHENTICATED|401|403/i.test(message)
  ) {
    return new Error("Gemini key missing or invalid in Backend .env (GEMINI_API_KEY)");
  }
  return err instanceof Error ? err : new Error(message);
};

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
  if (!process.env.GEMINI_API_KEY) {
    throw new Error("Gemini key missing or invalid in Backend .env (GEMINI_API_KEY)");
  }
  let lastError;
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const result = await model.generateContent(content);
      const text = (await result.response).text().trim();
      return parseGeminiJson(text);
    } catch (err) {
      lastError = normalizeGeminiError(err);
      if (isRetryableGeminiError(err) && attempt < maxAttempts) {
        await sleep(1000 * attempt);
        continue;
      }
      throw lastError;
    }
  }
  throw normalizeGeminiError(lastError);
};

export const generateJsonFromPrompt = async (prompt, maxAttempts = 3) =>
  runGeminiWithRetry(prompt, maxAttempts);

/**
 * Multimodal Gemini call (text + inline audio/image parts).
 * @param {Array<string|{text?:string,inlineData?:{mimeType:string,data:string}}>} parts
 */
export const generateJsonFromMultimodal = async (parts, maxAttempts = 3) =>
  runGeminiWithRetry(parts, maxAttempts);
