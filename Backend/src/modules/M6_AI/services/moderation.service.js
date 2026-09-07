import { processContentForModeration } from "../processors (Input Cleaning)/community.processor.js";
import {
  buildCommunityModerationPrompt,
  buildCommentModerationPrompt,
} from "../prompts/moderation.prompt.js";
import { generateJsonFromPrompt } from "../utils/gemini.helper.js";

const safeModerationFallback = () => ({
  isFlagged: false,
  flaggedBy: null,
  reason: null,
  severity: null,
  categories: [],
  preFilter: false,
});

const normalizeAiResult = (result, preFilter = false) => ({
  isFlagged: Boolean(result?.isFlagged),
  flaggedBy: result?.isFlagged ? "ai" : null,
  reason: result?.reason ?? null,
  severity: result?.severity ?? null,
  categories: Array.isArray(result?.categories) ? result.categories : [],
  preFilter,
});

export const moderatePost = async ({ title, content }) => {
  try {
    const processed = processContentForModeration(`${title || ""} ${content || ""}`);

    if (processed.preFilterTriggered) {
      const dominantFlag = Object.entries(processed.flags).find(([, v]) => v)?.[0];
      return {
        isFlagged: true,
        flaggedBy: "ai",
        reason: `Pre-filter: ${dominantFlag}`,
        severity: "medium",
        categories: Object.keys(processed.flags).filter((k) => processed.flags[k]),
        preFilter: true,
      };
    }

    const prompt = buildCommunityModerationPrompt({
      title,
      content: processed.cleaned,
      preFlags: null,
    });
    const result = await generateJsonFromPrompt(prompt);
    return normalizeAiResult(result, false);
  } catch (err) {
    console.warn("Gemini post moderation failed (allowing publish):", err.message);
    return safeModerationFallback();
  }
};

export const moderateComment = async ({ content }) => {
  try {
    const processed = processContentForModeration(content || "");

    if (processed.preFilterTriggered) {
      const dominantFlag = Object.entries(processed.flags).find(([, v]) => v)?.[0];
      return {
        isFlagged: true,
        flaggedBy: "ai",
        reason: `Pre-filter: ${dominantFlag}`,
        severity: "medium",
        categories: Object.keys(processed.flags).filter((k) => processed.flags[k]),
        preFilter: true,
      };
    }

    const prompt = buildCommentModerationPrompt({
      content: processed.cleaned,
      preFlags: null,
    });
    const result = await generateJsonFromPrompt(prompt);
    return normalizeAiResult(result, false);
  } catch (err) {
    console.warn("Gemini comment moderation failed (allowing publish):", err.message);
    return safeModerationFallback();
  }
};
