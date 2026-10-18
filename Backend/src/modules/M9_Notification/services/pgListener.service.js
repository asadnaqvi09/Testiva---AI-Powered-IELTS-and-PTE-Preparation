import pool from '../../../config/db.js';
import { handleAdminSubscriptionNotification } from '../engine/notification.engine.js';

let listenerClient = null;
let reconnectAttempt = 0;
let reconnectTimer = null;

const BASE_DELAY_MS = 30_000;
const MAX_DELAY_MS = 10 * 60_000; // 10 minutes

function scheduleReconnect(io, reason) {
  if (reconnectTimer) return;
  const delay = Math.min(
    BASE_DELAY_MS * Math.pow(2, reconnectAttempt),
    MAX_DELAY_MS,
  );
  reconnectAttempt += 1;
  console.warn(
    `[PG Listener] ${reason}. Retry #${reconnectAttempt} in ${Math.round(delay / 1000)}s`,
  );
  reconnectTimer = setTimeout(() => {
    reconnectTimer = null;
    initPgListener(io);
  }, delay);
}

export const initPgListener = async (io) => {
  try {
    listenerClient = await pool.connect();
    reconnectAttempt = 0;
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
      scheduleReconnect(io, 'Connection lost');
    });
    listenerClient.on('error', (err) => {
      console.error('[PG Listener] Database error:', err.message || err);
      try { listenerClient.release(); } catch (e) { /* already released */ }
      scheduleReconnect(io, 'Socket error');
    });
  } catch (err) {
    console.error('[PG Listener] Initialization failed:', err.message || err);
    scheduleReconnect(io, 'Init failed');
  }
};
