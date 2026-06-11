import { redisClient } from "../config/redis.js";

export async function cacheGetJson(key) {
  try {
    const raw = await redisClient.get(key);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export async function cacheSetJson(key, value, ttlSeconds = 60) {
  try {
    await redisClient.set(key, JSON.stringify(value), "EX", ttlSeconds);
  } catch {
    return null;
  }
}

export async function cacheDel(key) {
  try {
    await redisClient.del(key);
  } catch {
    return null;
  }
}

export async function cacheDelMany(keys) {
  try {
    if (keys.length) await redisClient.del(...keys);
  } catch {
    return null;
  }
}

export async function cacheDelByPrefix(prefix) {
  try {
    for await (const keys of redisClient.scanStream({ match: `${prefix}*`, count: 200 })) {
      if (keys.length) await redisClient.del(...keys);
    }
  } catch {
   return null;
  }
}
