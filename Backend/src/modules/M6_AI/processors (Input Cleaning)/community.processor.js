import { Filter } from 'bad-words';

const filter = new Filter();

filter.addWords(
  'slur1', 'slur2', 'abuse1', 'harassment',
  'idiot', 'stupid', 'moron', 'imbecile'
);

const EXCESSIVE_CAPS_THRESHOLD = 0.6;
const MAX_URLS = 3;
const URL_REGEX = /https?:\/\/[^\s]+/gi;
const EMOJI_SPAM_REGEX = /(\p{Emoji}\s*){6,}/gu;

export const processContentForModeration = (text) => {
  const cleaned = text.trim().replace(/\s+/g, ' ');

  const hasProfanity = filter.isProfane(cleaned);
  const censored = hasProfanity ? filter.clean(cleaned) : cleaned;

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