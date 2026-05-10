export const buildCommunityModerationPrompt = ({ title, content, preFlags }) => {
  const context = preFlags
    ? `Pre-filter signals detected: ${Object.entries(preFlags)
        .filter(([, v]) => v)
        .map(([k]) => k)
        .join(', ')}.`
    : '';
  return `You are a strict content moderator for an academic test-prep community (IELTS, PTE, General English).
${context}
Analyze the following user-generated content and return ONLY a valid JSON object with no extra text.
Post Title: "${title}"
Post Content: "${content}"
Respond with this exact shape:
{
  "isFlagged": boolean,
  "reason": string | null,
  "severity": "low" | "medium" | "high" | null,
  "categories": string[]
}
Flag if content contains ANY of:
- Hate speech, slurs, or discrimination
- Personal attacks or harassment
- Sexually explicit or graphic violence
- Spam, phishing links, or promotions unrelated to academics
- Misinformation about exam policies or institutions
- Content clearly off-topic for a test-prep community
"reason" must be a concise, human-readable explanation for the flag (null if not flagged).
"categories" is an array of matched violation categories (empty array if none).
"severity" indicates risk level (null if not flagged).`;
};
export const buildCommentModerationPrompt = ({ content, preFlags }) => {
  const context = preFlags
    ? `Pre-filter signals detected: ${Object.entries(preFlags)
        .filter(([, v]) => v)
        .map(([k]) => k)
        .join(', ')}.`
    : '';
  return `You are a strict content moderator for an academic test-prep community.
${context}
Analyze this comment and return ONLY a valid JSON object with no extra text.
Comment: "${content}"
Respond with this exact shape:
{
  "isFlagged": boolean,
  "reason": string | null,
  "severity": "low" | "medium" | "high" | null,
  "categories": string[]
}
Apply the same community standards: hate speech, harassment, spam, explicit content, off-topic promotion, or misinformation.`;
};