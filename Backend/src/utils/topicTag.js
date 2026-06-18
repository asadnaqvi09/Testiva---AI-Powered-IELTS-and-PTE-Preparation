export const TOPIC_TAGS = ["IELTS", "PTE", "General"];

export const normalizeTopicTag = (tag) => {
  if (!tag || typeof tag !== "string") return "General";
  const trimmed = tag.trim();
  if (trimmed.toUpperCase() === "GENERAL") return "General";
  if (trimmed === "IELTS" || trimmed === "PTE") return trimmed;
  return "General";
};

export const isGeneralTopicTag = (tag) => normalizeTopicTag(tag) === "General";
