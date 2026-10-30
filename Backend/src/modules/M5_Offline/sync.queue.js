import Queue from 'bull';
import { getRedisConnectionOptions } from '../../config/redis.js';

// This is a comment: Bull uses same REDIS_URL / host as ioredis
const redisOpts = getRedisConnectionOptions();

export const syncQueue = new Queue('sync-tests', {
    redis: {
        host: redisOpts.host,
        port: redisOpts.port,
        ...(redisOpts.password ? { password: redisOpts.password } : {}),
        ...(redisOpts.db ? { db: redisOpts.db } : {}),
    },
});

syncQueue.on('error', (error) => {
    console.error('[BULL QUEUE SYSTEM ERROR]: ', error);
});

export const addSyncJob = async (syncData) => {
    return await syncQueue.add(syncData, {
        attempts: 3,
        backoff: {
            type: 'exponential',
            delay: 5000
        },
        removeOnComplete: true,
        removeOnFail: false
    });
};
