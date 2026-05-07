import { generateAccessToken } from '../utils/jwt.js';
import {
  markUserOnline,
  markUserOffline,
  refreshPresence,
  getOnlineCount,
} from '../modules/M6_AI/ai/services/presence.service.js';;

const PING_INTERVAL = 20_000;

export const registerCommunitySocket = (io) => {
  const community = io.of('/community');

  community.use(async (socket, next) => {
    try {
      const token =
        socket.handshake.auth?.token ||
        socket.handshake.headers?.authorization?.split(' ')[1];
      if (!token) return next(new Error('UNAUTHORIZED'));
      const payload = generateAccessToken(token);
      socket.userId = payload.id;
      next();
    } catch {
      next(new Error('UNAUTHORIZED'));
    }
  });

  community.on('connection', async (socket) => {
    await markUserOnline(socket.userId);
    const count = await getOnlineCount();
    community.emit('online_count', { count });

    const pingTimer = setInterval(async () => {
      await refreshPresence(socket.userId);
    }, PING_INTERVAL);

    socket.on('new_post', (payload) => {
      socket.broadcast.emit('post_created', payload);
    });

    socket.on('post_liked', (payload) => {
      socket.broadcast.emit('post_like_updated', payload);
    });

    socket.on('new_comment', (payload) => {
      socket.broadcast.emit('comment_created', payload);
    });

    socket.on('comment_liked', (payload) => {
      socket.broadcast.emit('comment_like_updated', payload);
    });

    socket.on('disconnect', async () => {
      clearInterval(pingTimer);
      await markUserOffline(socket.userId);
      const updated = await getOnlineCount();
      community.emit('online_count', { count: updated });
    });
  });
};