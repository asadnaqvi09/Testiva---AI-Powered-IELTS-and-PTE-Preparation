import pool from "../../../config/db.js";
import { sendNotification, sendBulkNotifications } from "../services/notification.service.js";
import { emitPostRemovedFromFeed } from "../socketIO/event.engine.js";

// =========================================================================
// 1. USER SIDE NOTIFICATIONS (Dispatched to Users based on Preferences/Actions)
// =========================================================================

export const handlePostCreatedNotification = async (io, post) => {
    const { topic_tag, user_id: authorId, id: postId, title: postTitle } = post;
    
    // Convert to exact casing to match DB check if necessary (e.g., General, IELTS, PTE)
    if (!topic_tag || topic_tag.toUpperCase() === "GENERAL") return;
    
    const result = await pool.query(
        `SELECT id FROM users 
         WHERE (preference = $1) 
         AND id != $2`,
        [topic_tag, authorId]
    );
    
    const recipientIds = r
    esult.rows.map(r => r.id);
    if (!recipientIds.length) return;

    return sendBulkNotifications({
        io,
        recipientIds,
        senderId: authorId,
        type: "admin_new_post", // Fixed to match DB Enum for general community broadcast
        title: `New ${topic_tag} Post`,
        message: `A new post was created: ${postTitle}`,
        post_id: postId // Changed from entityId to match database schema mapping
    });
};

export const handleLikeNotification = async (io, { actorId, actorName, postOwnerId, postId }) => {
    if (actorId === postOwnerId) return;
    return sendNotification({
        io,
        recipientId: postOwnerId,
        senderId: actorId,
        type: "post_like", // Verified DB Enum matches
        title: "New Like",
        message: `${actorName} liked your post.`,
        post_id: postId // Changed from entityId
    });
};

export const handleCommentNotification = async (io, { actorId, actorName, postOwnerId, postId }) => {
    if (actorId === postOwnerId) return;
    return sendNotification({
        io,
        recipientId: postOwnerId,
        senderId: actorId,
        type: "post_comment", // Verified DB Enum matches
        title: "New Comment",
        message: `${actorName} commented on your post.`,
        post_id: postId // Changed from entityId
    });
};

export const handleReplyNotification = async (io, { actorId, actorName, parentCommentOwnerId, postId, commentId }) => {
    if (actorId === parentCommentOwnerId) return;
    return sendNotification({
        io,
        recipientId: parentCommentOwnerId,
        senderId: actorId,
        type: "comment_reply", // Verified DB Enum matches
        title: "New Reply",
        message: `${actorName} replied to your comment.`,
        post_id: postId,
        comment_id: commentId // Explicitly mapped for granular context tracking
    });
};

export const handleModerationNotification = async (io, { postId, postOwnerId, action, adminFeedback }) => {
    let dbNotificationType;
    let title;

    // Dynamically mapping the correct DB Enum based on specific Admin actions
    if (action === "delete") {
        dbNotificationType = "post_deleted";
        title = "Post Deleted";
        emitPostRemovedFromFeed(io, postId);
    } else if (action === "unflag") {
        dbNotificationType = "post_unflagged";
        title = "Post Restored";
    } else {
        dbNotificationType = "post_flagged"; // Fallback/Default case for flag
        title = "Post Flagged";
    }

    const message = adminFeedback || `Your post was ${action}d by an admin for violating community guidelines.`;

    return sendNotification({
        io,
        recipientId: postOwnerId,
        type: dbNotificationType, // Dynamic type injection resolves DB validation errors
        title,
        message,
        post_id: postId // Changed from entityId
    });
};

// =========================================================================
// 2. ADMIN SIDE NOTIFICATIONS (Dispatched to Admin Dashboard Panels)
// =========================================================================

export const handleAdminNewUserNotification = async (io, newUser) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map(r => r.id);
    if (!adminIds.length) return;

    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        type: "admin_new_user", // Verified DB Enum matches
        title: "New User Registration",
        message: `${newUser.full_name} (${newUser.email}) just joined the platform.`,
        senderId: newUser.id // Tracking who triggered the admin notification payload
    });
};

export const handleAdminNewPostNotification = async (io, newPost) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map(r => r.id);
    if (!adminIds.length) return;

    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        type: "admin_new_post", // Verified DB Enum matches
        title: "New Community Post",
        message: `A new post was created in the ${newPost.topic_tag} tag.`,
        post_id: newPost.id, // Changed from entityId
        senderId: newPost.user_id
    });
};

export const handleAdminSubscriptionNotification = async (io, payload) => {
    const result = await pool.query(`SELECT id FROM users WHERE role = 'admin'`);
    const adminIds = result.rows.map(r => r.id);
    if (!adminIds.length) return;

    return sendBulkNotifications({
        io,
        recipientIds: adminIds,
        type: "admin_subscription_changed", // Verified DB Enum matches
        title: "Manual Subscription Update",
        message: `${payload.full_name}'s subscription was manually changed from ${payload.old_sub} to ${payload.new_sub}.`,
        senderId: payload.user_id // Maps accurately to user context fields
    });
};