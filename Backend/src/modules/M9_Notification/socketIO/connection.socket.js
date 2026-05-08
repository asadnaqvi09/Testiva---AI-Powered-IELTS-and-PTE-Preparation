import jwt from "jsonwebtoken";
import { resolveUserRooms } from "../services/socketRoom.service.js";
import { emitOnlineCount } from "./event.engine.js";
import {
  markUserOnline,
  markUserOffline,
  refreshPresence,
  getOnlineCount,
  cleanupExpiredUsers
} from "../../M6_AI/ai/services/presence.service.js";

const PING_INTERVAL = 20000;

export const registerConnectionSocket = (io) => {
  const community = io.of("/community");

  community.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(" ")[1];
      if (!token) return next(new Error("UNAUTHORIZED"));
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.user = {
        id: decoded.id,
        role: decoded.role,
        preferences: decoded.preferences || null
      };
      next();
    } catch {
      next(new Error("UNAUTHORIZED"));
    }
  });

  community.on("connection", async (socket) => {
    const { user } = socket;
    await markUserOnline(user.id, user.preferences);
    const rooms = resolveUserRooms(user);
    socket.join(rooms);
    const count = await getOnlineCount();
    emitOnlineCount(io, count);
    socket.emit("connected", { userId: user.id, rooms });
    const ping = setInterval(() => refreshPresence(user.id), PING_INTERVAL);
    socket.on("disconnect", async () => {
      clearInterval(ping);
      await markUserOffline(user.id, user.preferences);
      await cleanupExpiredUsers();
      const updatedCount = await getOnlineCount();
      emitOnlineCount(io, updatedCount);
    });
  });
};