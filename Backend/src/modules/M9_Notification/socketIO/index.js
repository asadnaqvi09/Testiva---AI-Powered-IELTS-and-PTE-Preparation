import { registerConnectionSocket } from "./connection.socket.js";
import { registerCommunityEvents } from "./community.socket.js";

/**
 * Initialize all Socket.io namespaces and event handlers.
 * @param {import("socket.io").Server} io
 */
export const initSocketIO = (io) => {
  registerConnectionSocket(io);
  registerCommunityEvents(io);
};