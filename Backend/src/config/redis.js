import Redis from "ioredis";

// This is a comment: single Redis source for ioredis + Bull (REDIS_URL preferred)
const DEFAULT_REDIS_URL = "redis://localhost:6379";

export function getRedisConnectionOptions() {
  const url = (process.env.REDIS_URL || "").trim();
  if (url) {
    try {
      const parsed = new URL(url);
      return {
        host: parsed.hostname || "127.0.0.1",
        port: Number(parsed.port) || 6379,
        password: parsed.password || undefined,
        db: parsed.pathname && parsed.pathname.length > 1
          ? Number(parsed.pathname.slice(1)) || 0
          : 0,
        url,
      };
    } catch {
      // fall through to host/port
    }
  }
  const host = process.env.REDIS_HOST || "127.0.0.1";
  const port = Number(process.env.REDIS_PORT) || 6379;
  const password = process.env.REDIS_PASSWORD || undefined;
  return {
    host,
    port,
    password,
    db: 0,
    url: password
      ? `redis://:${encodeURIComponent(password)}@${host}:${port}`
      : `redis://${host}:${port}`,
  };
}

const redisOpts = getRedisConnectionOptions();
const redisClient = new Redis(redisOpts.url || DEFAULT_REDIS_URL);

redisClient.on("connect", () => console.log("Redis Connected"));
redisClient.on("error", (err) => console.error("Redis Error:", err));

export { redisClient };