import { OAuth2Client } from "google-auth-library";

const client = new OAuth2Client();

const googleAudiences = () => {
  const ids = [process.env.GOOGLE_CLIENT_ID, process.env.GOOGLE_ANDROID_CLIENT_ID]
    .map((value) => (value || "").trim())
    .filter(Boolean);
  if (ids.length === 0) return null;
  return ids.length === 1 ? ids[0] : ids;
};

const classifyGoogleTokenError = (error) => {
  const raw = error?.message || "Invalid Google ID token";
  const err = new Error("Invalid Google ID token");
  err.statusCode = 401;
  if (/Wrong recipient|audience/i.test(raw)) {
    err.message =
      "Google token audience mismatch. GOOGLE_CLIENT_ID must match the Flutter Web client ID (serverClientId).";
  } else if (/too late|expired/i.test(raw)) {
    err.message = "Google token expired. Please try again.";
  } else if (/too early/i.test(raw)) {
    err.message =
      "Google token not yet valid. Check the device clock and try again.";
  } else if (/certificate|pem|Failed to retrieve/i.test(raw)) {
    err.message = "Could not verify Google token (certificate fetch failed).";
  } else if (/segments|envelope|signature|issuer/i.test(raw)) {
    err.message = "Invalid Google ID token.";
  }
  return err;
};

export const verifyGoogleToken = async (idToken) => {
  const audience = googleAudiences();
  if (!audience) {
    const err = new Error("GOOGLE_CLIENT_ID is not configured on the server.");
    err.statusCode = 500;
    throw err;
  }
  try {
    const ticket = await client.verifyIdToken({ idToken, audience });
    const payload = ticket.getPayload();
    if (!payload?.email) {
      const err = new Error("Google token did not include an email address.");
      err.statusCode = 401;
      throw err;
    }
    return {
      email: payload.email,
      full_name: payload.name || payload.email.split("@")[0],
      avatar_url: payload.picture || null,
      email_verified:
        payload.email_verified === true || payload.email_verified === "true",
    };
  } catch (error) {
    if (error.statusCode) throw error;
    throw classifyGoogleTokenError(error);
  }
};
