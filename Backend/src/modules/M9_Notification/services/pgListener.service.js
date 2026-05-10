import pool from '../../../config/db.js';
import { handleAdminSubscriptionNotification } from '../engine/notification.engine.js';

let listenerClient = null;

export const initPgListener = async (io) => {
  try {
    listenerClient = await pool.connect();
    listenerClient.on('notification', async (msg) => {
      if (msg.channel === 'subscription_changes') {
        const payload = JSON.parse(msg.payload);
        console.log('[PG Listener] Subscription Change Detected:', payload);
        await handleAdminSubscriptionNotification(io, payload);
      }
    });
    await listenerClient.query('LISTEN subscription_changes');
    console.log('[PG Listener] Connected and listening to subscription_changes');
    listenerClient.on('end', () => {
      console.log('[PG Listener] Connection lost, reconnecting...');
      setTimeout(() => initPgListener(io), 5000);
    });
    listenerClient.on('error', (err) => {
      console.error('[PG Listener] Database error:', err);
      try { listenerClient.release(); } catch(e) {}
      setTimeout(() => initPgListener(io), 5000);
    });
  } catch (err) {
    console.error('[PG Listener] Initialization failed:', err);
    setTimeout(() => initPgListener(io), 5000);
  }
};
