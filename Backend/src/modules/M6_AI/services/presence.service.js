import { redisClient as redis } from "../../../config/redis.js";
const PRESENCE_KEY = "presence:user:";
const ROOM_KEY = "presence:room:";
const LAST_SEEN_KEY = "presence:last_seen:";
const TTL_SECONDS = 35;
export const markUserOnline = async (userId, preference = "GENERAL") => {
  const pref = preference || "GENERAL";
  await redis.pipeline()
    .setex(`${PRESENCE_KEY}${userId}`, TTL_SECONDS, pref)
    .sadd(`${ROOM_KEY}${pref}`, userId)
    .set(`${LAST_SEEN_KEY}${userId}`, Date.now())
    .exec();
};
export const markUserOffline = async (userId, preference = null) => {
  const pref = preference || (await redis.get(`${PRESENCE_KEY}${userId}`));
  const multi = redis.multi();
  multi.del(`${PRESENCE_KEY}${userId}`);
  multi.del(`${LAST_SEEN_KEY}${userId}`);
  if (pref) {
    multi.srem(`${ROOM_KEY}${pref}`, userId);
  }
  await multi.exec();
};
export const refreshPresence = async (userId) => {
  const pref = await redis.get(`${PRESENCE_KEY}${userId}`);
  if (!pref) return;
  await redis.pipeline()
    .setex(`${PRESENCE_KEY}${userId}`, TTL_SECONDS, pref)
    .set(`${LAST_SEEN_KEY}${userId}`, Date.now())
    .exec();
};
export const getOnlineCount = async (preference = null) => {
  if (preference) {
    return await redis.scard(`${ROOM_KEY}${preference}`);
  }
  const keys = await redis.keys(`${PRESENCE_KEY}*`);
  return keys.length;
};
export const getRoomOnlineUsers = async (preference) => {
  return await redis.smembers(`${ROOM_KEY}${preference}`);
};
export const getLastSeen = async (userId) => {
  const ts = await redis.get(`${LAST_SEEN_KEY}${userId}`);
  return ts ? Number(ts) : null;
};
export const cleanupExpiredUsers = async () => {
  const keys = await redis.keys(`${PRESENCE_KEY}*`);
  const activeUserIds = keys.map(k => k.replace(PRESENCE_KEY, ""));

  const lastSeenKeys = await redis.keys(`${LAST_SEEN_KEY}*`);
  for (const lsKey of lastSeenKeys) {
    const userId = lsKey.replace(LAST_SEEN_KEY, "");
    if (!activeUserIds.includes(userId)) {
      await redis.del(lsKey);
    }
  }
};