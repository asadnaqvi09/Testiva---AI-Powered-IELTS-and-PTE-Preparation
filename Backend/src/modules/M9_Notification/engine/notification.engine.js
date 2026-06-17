import pool from "../../../config/db.js";
import { sendNotification, sendBulkNotifications } from "../services/notification.service.js";
import { emitPostRemovedFromFeed } from "../socketIO/event.engine.js";

export const handlePostCreatedNotification = async (io, post) => {
    const { topic_tag, user_id: authorId, id: postId, title: postTitle } = post;
    if (!topic_tag || topic_tag.toUpperCase() === "GENERAL") return;

    const result = await pool.query(
        `SELECT id FROM users
         WHERE preference = $1
         AND id != $2`,
        [topic_tag, authorId]
    );

    const recipientIds = result.rows.map((row) => row.id);
    if (!recipientIds.length) return;

    return sendBulkNotifications({
        io,
        recipientIds,
        senderId: authorId,
        type: "preference_new_post",
        title: `New ${topic_tag} Post`,
        message: `A new post was created: ${postTitle}`,
        postId,
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
        postId,
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
        postId,
    });
};

export const handleReplyNotification = async (io, { actorId, actorName, parentCommentOwnerId, postId, commentId }) => {
    if (actorId === parentCommentOwnerId) return;
    return sendNotification({
        io,
        recipientId: parentCommentOwnerId,
        senderId: actorId,
        type: "comment_reply",
        title: "New Reply",
        message: `${actorName} replied to your comment.`,
        postId,
        commentId,
    });
};

export const handleModerationNotification = async (io, { postId, postOwnerId, action, adminFeedback }) => {
    let dbNotificationType;
    let title;
    if (action === "delete") {
        dbNotificationType = "post_deleted";
        title = "Post Deleted";
        emitPostRemovedFromFeed(io, postId);
    } else if (action === "unflag") {
        dbNotificationType = "post_unflagged";
        title = "Post Restored";
    } else {
        dbNotificationType = "post_flagged";
        title = "Post Flagged";
    }

    const message = adminFeedback || `Your post was ${action}d by an admin for violating community guidelines.`;

    return sendNotification({
        io,
        recipientId: postOwnerId,
        type: dbNotificationType,
        title,
        message,
        postId,
    });
};

export const handleAdminNewUserNotification = async (io, newUser) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map((row) => row.id);
    if (!adminIds.length) return;
    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        type: "admin_new_user",
        title: "New User Registration",
        message: `${newUser.full_name} (${newUser.email}) just joined the platform.`,
        senderId: newUser.id,
    });
};

export const handleAdminNewPostNotification = async (io, newPost) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map((row) => row.id);
    if (!adminIds.length) return;
    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        type: "admin_new_post",
        title: "New Community Post",
        message: `A new post was created in the ${newPost.topic_tag} tag.`,
        postId: newPost.id,
        senderId: newPost.user_id,
    });
};

export const handleAdminPreferenceChangeNotification = async (io, { user, targetPreference, feedback }) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map((row) => row.id);
    if (!adminIds.length) return;
    const summary = feedback?.trim() ? `: ${feedback.trim().slice(0, 120)}` : "";
    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        senderId: user.id,
        type: "preference_change_request",
        title: "Preference Change Request",
        message: `${user.full_name} (${user.email}) requested a change from ${user.preference || "none"} to ${targetPreference}${summary}`,
    });
};

export const handleAdminSubscriptionNotification = async (io, payload) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map((row) => row.id);
    if (!adminIds.length) return;
    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        type: "admin_subscription_changed",
        title: "Manual Subscription Update",
        message: `${payload.full_name}'s subscription was manually changed from ${payload.old_sub} to ${payload.new_sub}.`,
        senderId: payload.user_id,
    });
};
