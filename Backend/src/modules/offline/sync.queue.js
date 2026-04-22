import Queue from 'bull';
import pool from '../../config/db.js';

export const syncQueue = new Queue('sync-tests', {
    redis : {
        host : process.env.REDIS_HOST || '127.0.0.1',
        port : process.env.REDIS_PORT || 6379
    }
});

export const addSyncJob = async (syncData) => {
    return await syncQueue.add(syncData, {
        attempts : 3,
        backoff : 5000
    })
}