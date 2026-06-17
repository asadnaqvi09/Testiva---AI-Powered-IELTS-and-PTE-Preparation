import { model } from "../../../config/gemini.js";

export const parseGeminiJson = (rawText) => {
  const clean = rawText.replace(/```json|```/gi, "").trim();
  return JSON.parse(clean);
};

export const generateJsonFromPrompt = async (prompt) => {
  const result = await model.generateContent(prompt);
  const text = (await result.response).text().trim();
  return parseGeminiJson(text);
};
