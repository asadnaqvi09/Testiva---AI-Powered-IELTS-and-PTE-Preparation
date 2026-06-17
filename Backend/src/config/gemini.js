import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

export const GEMINI_MODEL_ID = process.env.GEMINI_MODEL || "gemini-2.5-flash";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

export const model = genAI.getGenerativeModel({
  model: GEMINI_MODEL_ID,
  generationConfig: {
    responseMimeType: "application/json",
    temperature: 0.7,
    maxOutputTokens: 2000,
  },
});
