import Redis from 'ioredis';
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
const PRESENCE_KEY = 'community:online_users';
const TTL_SECONDS = 30;
export const markUserOnline = async (userId) => {
  await redis.setex(`${PRESENCE_KEY}:${userId}`, TTL_SECONDS, '1');
  await redis.sadd(PRESENCE_KEY, userId);
};
export const markUserOffline = async (userId) => {
  await redis.del(`${PRESENCE_KEY}:${userId}`);
  await redis.srem(PRESENCE_KEY, userId);
};
export const refreshPresence = async (userId) => {
  await redis.setex(`${PRESENCE_KEY}:${userId}`, TTL_SECONDS, '1');
};
export const getOnlineCount = async () => {
  const members = await redis.smembers(PRESENCE_KEY);
  const pipeline = redis.pipeline();
  members.forEach((uid) => pipeline.exists(`${PRESENCE_KEY}:${uid}`));
  const results = await pipeline.exec();
  const active = results.filter(([, v]) => v === 1);
  const expired = members.filter((_, i) => results[i][1] === 0);
  if (expired.length > 0) {
    await redis.srem(PRESENCE_KEY, ...expired);
  }
  return active.length;
};