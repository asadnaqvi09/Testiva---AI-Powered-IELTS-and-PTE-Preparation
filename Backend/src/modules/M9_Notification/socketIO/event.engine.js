import { getCommunityRoom, getUserRoom } from "../services/socketRoom.service.js";

const namespace = (io) => io.of("/community");

export const emitToUser = (io, userId, event, payload) => {
  namespace(io).to(getUserRoom(userId)).emit(event, payload);
};
export const emitToCommunity = (io, tag, event, payload) => {
  namespace(io).to(getCommunityRoom(tag)).emit(event, payload);
};
export const emitToAllCommunities = (io, event, payload) => {
  namespace(io).emit(event, payload);
};
// --- Feed Events ---
export const emitPostCreated = (io, post) => {
  emitToCommunity(io, post.topic_tag, "post_created", post);
};
export const emitPostLiked = (io, data) => {
  emitToCommunity(io, data.topic_tag, "post_like_updated", data);
};
export const emitCommentCreated = (io, data) => {
  emitToCommunity(io, data.topic_tag, "comment_created", data);
};
export const emitCommentLiked = (io, data) => {
  emitToCommunity(io, data.topic_tag, "comment_like_updated", data);
};
// --- Moderation Events ---
export const emitPostRemovedFromFeed = (io, postId) => {
  emitToAllCommunities(io, "post:removed", { postId });
};
export const emitPostFlagged = (io, userId, payload) => {
  emitToUser(io, userId, "post:flagged", payload);
};
// --- Presence Events ---
export const emitOnlineCount = (io, count) => {
  emitToAllCommunities(io, "online_count", { count });
};