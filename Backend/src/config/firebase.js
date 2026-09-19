import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import admin from "firebase-admin";
import "./env.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const backendRoot = path.resolve(__dirname, "../..");

let isFirebaseInitialized = false;

const resolveCredentialsPath = () => {
  const raw = (process.env.GOOGLE_APPLICATION_CREDENTIALS || "").trim();
  if (!raw) return null;
  if (path.isAbsolute(raw)) return raw;
  // Resolve relative to Backend/ (where `node` is usually started)
  return path.resolve(backendRoot, raw);
};

try {
  const credPath = resolveCredentialsPath();
  if (!credPath) {
    console.warn(
      "[Firebase Admin] GOOGLE_APPLICATION_CREDENTIALS not set. " +
        "In-app Socket notifications still work; native FCM push is skipped.",
    );
  } else if (!fs.existsSync(credPath)) {
    console.warn(
      `[Firebase Admin] Credentials file missing at ${credPath}. ` +
        "Download a Firebase service account JSON, save it there " +
        "(gitignored), and restart. Socket notifications still work.",
    );
  } else {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(fs.readFileSync(credPath, "utf8"))),
    });
    isFirebaseInitialized = true;
    console.log("[Firebase Admin] Push notifications ready:", credPath);
  }
} catch (error) {
  console.error("[Firebase Admin] Initialization Error:", error.message);
  console.warn("[Firebase Admin] Continuing without push notifications...");
}

export const sendPushNotification = async (token, title, body, data = {}) => {
  if (!isFirebaseInitialized || !token) return false;
  try {
    // clean and optimized code — FCM data values must be strings
    const stringData = {};
    for (const [key, value] of Object.entries(data || {})) {
      if (value == null) continue;
      stringData[key] = String(value);
    }
    const payload = {
      notification: { title, body },
      data: {
        ...stringData,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "testiva_alerts",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      token,
    };
    const response = await admin.messaging().send(payload);
    console.log("[Firebase Admin] Successfully sent message:", response);
    return true;
  } catch (error) {
    console.error(
      `[Firebase Admin] Failed to send push notification to token ${token}:`,
      error.message,
    );
    return false;
  }
};

export const isFcmReady = () => isFirebaseInitialized;
