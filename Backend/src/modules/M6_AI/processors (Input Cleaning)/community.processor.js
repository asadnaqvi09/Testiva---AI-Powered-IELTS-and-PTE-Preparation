const BLOCKED_WORDS = [
  "idiot",
  "stupid",
  "moron",
  "imbecile",
  "hateyou",
  "kill yourself",
  "kys",
];

const EXCESSIVE_CAPS_THRESHOLD = 0.6;
const MAX_URLS = 3;
const URL_REGEX = /https?:\/\/[^\s]+/gi;
const EMOJI_SPAM_REGEX = /(\p{Emoji}\s*){6,}/gu;

const hasBlockedLanguage = (text) => {
  const lower = text.toLowerCase();
  return BLOCKED_WORDS.some((word) => lower.includes(word));
};

const censorBlockedWords = (text) => {
  let result = text;
  for (const word of BLOCKED_WORDS) {
    const escaped = word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    result = result.replace(new RegExp(escaped, "gi"), "***");
  }
  return result;
};

export const processContentForModeration = (text) => {
  const cleaned = String(text || "")
    .trim()
    .replace(/\s+/g, " ");

  const hasProfanity = hasBlockedLanguage(cleaned);
  const censored = hasProfanity ? censorBlockedWords(cleaned) : cleaned;

  const upperCount = (cleaned.match(/[A-Z]/g) || []).length;
  const letterCount = (cleaned.match(/[a-zA-Z]/g) || []).length;
  const capsRatio = letterCount > 0 ? upperCount / letterCount : 0;
  const isExcessiveCaps = capsRatio > EXCESSIVE_CAPS_THRESHOLD && cleaned.length > 20;

  const urlMatches = cleaned.match(URL_REGEX) || [];
  const hasSpamUrls = urlMatches.length > MAX_URLS;

  const hasEmojiSpam = EMOJI_SPAM_REGEX.test(cleaned);

  return {
    original: text,
    cleaned: censored,
    flags: {
      hasProfanity,
      isExcessiveCaps,
      hasSpamUrls,
      hasEmojiSpam,
    },
    preFilterTriggered: hasProfanity || isExcessiveCaps || hasSpamUrls || hasEmojiSpam,
  };
};
