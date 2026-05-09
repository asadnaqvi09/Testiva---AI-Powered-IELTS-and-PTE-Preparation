import pool from "../../../config/db.js";
import { sendNotification, sendBulkNotifications } from "../services/notification.service.js";
import { emitPostRemovedFromFeed } from "../socketIO/event.engine.js";

export const handlePostCreatedNotification = async (io, post) => {
    const { topic_tag, user_id: authorId, id: postId, title: postTitle } = post;
    if (!topic_tag || topic_tag === "GENERAL") return;
    const result = await pool.query(
        `SELECT id FROM users 
     WHERE (preference = $1) 
     AND id != $2`,
        [topic_tag, authorId]
    );
    const recipientIds = result.rows.map(r => r.id);
    return sendBulkNotifications({
        io,
        recipientIds,
        senderId: authorId,
        type: "post_created",
        title: `New ${topic_tag} Post`,
        message: `A new post was created: ${postTitle}`,
        entityId: postId,
        entityType: "post"
    });
};

export const handleLikeNotification = async (io, { actorId, actorName, postOwnerId, postId }) => {
    if (actorId === postOwnerId) return;
    return sendNotification({
        io,
        recipientId: postOwnerId,
        senderId: actorId,
        type: "post_like",
        title: "New Like",
        message: `${actorName} liked your post.`,
        entityId: postId,
        entityType: "post"
    });
};

export const handleCommentNotification = async (io, { actorId, actorName, postOwnerId, postId }) => {
    if (actorId === postOwnerId) return;
    return sendNotification({
        io,
        recipientId: postOwnerId,
        senderId: actorId,
        type: "post_comment",
        title: "New Comment",
        message: `${actorName} commented on your post.`,
        entityId: postId,
        entityType: "post"
    });
};

export const handleReplyNotification = async (io, { actorId, actorName, parentCommentOwnerId, postId }) => {
    if (actorId === parentCommentOwnerId) return;
    return sendNotification({
        io,
        recipientId: parentCommentOwnerId,
        senderId: actorId,
        type: "comment_reply",
        title: "New Reply",
        message: `${actorName} replied to your comment.`,
        entityId: postId,
        entityType: "post"
    });
};

export const handleModerationNotification = async (io, { postId, postOwnerId, action, adminFeedback }) => {
    const title = action === "delete" ? "Post Deleted" : "Post Flagged";
    const message = adminFeedback || `Your post was ${action}d by an admin for violating community guidelines.`;
    if (action === "delete") {
        emitPostRemovedFromFeed(io, postId);
    }
    return sendNotification({
        io,
        recipientId: postOwnerId,
        type: "moderation",
        title,
        message,
        entityId: postId,
        entityType: "post"
    });
};