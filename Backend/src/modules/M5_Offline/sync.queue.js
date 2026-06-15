import Queue from 'bull';

export const syncQueue = new Queue('sync-tests', {
    redis: {
        host: process.env.REDIS_HOST || '127.0.0.1',
        port: process.env.REDIS_PORT || 6379
    }
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