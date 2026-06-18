import admin from 'firebase-admin';
import './env.js';

let isFirebaseInitialized = false;

try {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    isFirebaseInitialized = true;
    console.log('[Firebase Admin] Successfully initialized Push Notifications');
  } else {
    console.warn('[Firebase Admin] GOOGLE_APPLICATION_CREDENTIALS not found. FCM Push Notifications will be gracefully bypassed.');
  }
} catch (error) {
  console.error('[Firebase Admin] Initialization Error:', error.message);
  console.warn('[Firebase Admin] Continuing without push notifications...');
}
export const sendPushNotification = async (token, title, body, data = {}) => {
  if (!isFirebaseInitialized || !token) return false;
  try {
    const payload = {
      notification: { title, body },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      token
    };
    const response = await admin.messaging().send(payload);
    console.log(`[Firebase Admin] Successfully sent message:`, response);
    return true;
  } catch (error) {
    console.error(`[Firebase Admin] Failed to send push notification to token ${token}:`, error.message);
    return false;
  }
};
