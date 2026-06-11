/**
 * community.socket.js
 *
 * Server-side community event registration on the /community namespace.
 *
 * IMPORTANT: All community events (post created, liked, commented, moderated)
 * are triggered by REST API handlers — NOT by client socket events.
 * Clients should NEVER emit post:create, post:like, etc. directly.
 *
 * This file is intentionally minimal. Feed updates and notifications are
 * dispatched from the controller layer via event.engine.js helpers.
 */

/**
 * @param {import("socket.io").Server} io
 */
export const registerCommunityEvents = (io) => {
  const community = io.of("/community");

  // No client-driven event listeners needed.
  // All socket emissions originate from the REST API layer:
  //   POST /community        → emitPostCreated()
  //   POST /community/:id/like  → emitPostLiked()
  //   POST /community/:id/comments → emitCommentCreated()
  //   POST /comments/:id/like  → emitCommentLiked()
  //   DELETE /admin/posts/:id  → emitPostRemovedFromFeed()
  //   POST /admin/posts/:id/flag → emitToUser() (owner only)

  // Expose namespace for use in event.engine.js if needed
  return community;
};