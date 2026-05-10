import { aiService } from '../services/ai.service.js';
import { processContentForModeration } from '../processors (Input Cleaning)/community.processor.js';
import {
  buildCommunityModerationPrompt,
  buildCommentModerationPrompt,
} from '../prompts/moderation.prompt.js';

const parseModerationResponse = (raw) => {
  try {
    const text = raw?.content?.[0]?.text || '';
    const clean = text.replace(/```json|```/g, '').trim();
    return JSON.parse(clean);
  } catch {
    return { isFlagged: false, reason: null, severity: null, categories: [] };
  }
};

export const moderatePost = async ({ title, content }) => {
  const processed = processContentForModeration(`${title} ${content}`);

  if (processed.preFilterTriggered) {
    const dominantFlag = Object.entries(processed.flags).find(([, v]) => v)?.[0];
    return {
      isFlagged: true,
      flaggedBy: 'ai',
      reason: `Pre-filter: ${dominantFlag}`,
      severity: 'medium',
      categories: Object.keys(processed.flags).filter((k) => processed.flags[k]),
      preFilter: true,
    };
  }

  const prompt = buildCommunityModerationPrompt({
    title,
    content: processed.cleaned,
    preFlags: null,
  });

  const raw = await aiService(prompt);
  const result = parseModerationResponse(raw);

  return {
    isFlagged: result.isFlagged ?? false,
    flaggedBy: result.isFlagged ? 'ai' : null,
    reason: result.reason ?? null,
    severity: result.severity ?? null,
    categories: result.categories ?? [],
    preFilter: false,
  };
};

export const moderateComment = async ({ content }) => {
  const processed = processContentForModeration(content);

  if (processed.preFilterTriggered) {
    const dominantFlag = Object.entries(processed.flags).find(([, v]) => v)?.[0];
    return {
      isFlagged: true,
      flaggedBy: 'ai',
      reason: `Pre-filter: ${dominantFlag}`,
      severity: 'medium',
      categories: Object.keys(processed.flags).filter((k) => processed.flags[k]),
      preFilter: true,
    };
  }

  const prompt = buildCommentModerationPrompt({
    content: processed.cleaned,
    preFlags: null,
  });

  const raw = await aiService(prompt);
  const result = parseModerationResponse(raw);

  return {
    isFlagged: result.isFlagged ?? false,
    flaggedBy: result.isFlagged ? 'ai' : null,
    reason: result.reason ?? null,
    severity: result.severity ?? null,
    categories: result.categories ?? [],
    preFilter: false,
  };
};