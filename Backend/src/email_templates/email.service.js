import nodemailer from 'nodemailer';
import { registerOtpTemplate } from './templates/registerOtp.js';
import { resetOtpTemplate } from './templates/resetOtp.js';
import { postFlaggedTemplate } from './templates/postFlagged.js';
import { preferenceChangeRequestTemplate } from './templates/preferenceChangeRequest.js';

// Operator config only (Backend/.env) — never student-facing / never hardcode in the app:
//   EMAIL_USER = full Gmail address (or SMTP_USER)
//   EMAIL_PASS = 16-character Gmail App Password (or SMTP_PASS) — not your normal password
//   ALLOW_DEV_OTP = true  (optional FYP fallback ONLY when SMTP fails; omit for real email)
// Optional: SMTP_HOST (default smtp.gmail.com), SMTP_PORT (default 587)
// Spaces in App Passwords are stripped. Students only ever see a generic send-failed message.

const OTP_SEND_FAILED_MESSAGE = 'Could not send OTP. Please try again.';

let transporter = null;
let transporterFingerprint = '';

const getSmtpCredentials = () => {
  const user = String(process.env.SMTP_USER || process.env.EMAIL_USER || '').trim();
  const pass = String(process.env.SMTP_PASS || process.env.EMAIL_PASS || '')
    .trim()
    .replace(/\s+/g, '');
  return { user, pass };
};

/** Intentional FYP/demo fallback only — does NOT auto-enable just because NODE_ENV=development. */
const isDevOtpFallbackEnabled = () =>
  String(process.env.ALLOW_DEV_OTP || '').trim().toLowerCase() === 'true';

const isSmtpAuthFailure = (error) => {
  if (!error) return false;
  const smtpCode = error.responseCode || error.code;
  const smtpMessage = String(error.message || '');
  return (
    error.code === 'EAUTH' ||
    error.code === 'SMTP_CONFIG' ||
    Number(smtpCode) === 535 ||
    smtpMessage.includes('535') ||
    /Invalid login|BadCredentials|Username and Password not accepted/i.test(smtpMessage)
  );
};

const getTransporter = () => {
  const { user, pass } = getSmtpCredentials();
  if (!user || !pass) {
    console.error(
      '[EMAIL] Missing SMTP credentials. Set EMAIL_USER (full Gmail address) and EMAIL_PASS (16-character Gmail App Password, no spaces) in Backend/.env. SMTP_USER / SMTP_PASS are accepted as aliases. OTP emails will not be sent.',
    );
    return null;
  }

  const host = String(process.env.SMTP_HOST || 'smtp.gmail.com').trim() || 'smtp.gmail.com';
  const port = Number.parseInt(process.env.SMTP_PORT || '587', 10) || 587;
  const secure = port === 465;
  const fingerprint = `${host}:${port}:${secure}:${user}:${pass.length}`;

  if (transporter && transporterFingerprint === fingerprint) {
    return transporter;
  }

  transporter = nodemailer.createTransport({
    host,
    port,
    secure,
    auth: {
      user,
      pass,
    },
  });
  transporterFingerprint = fingerprint;
  return transporter;
};

const emailTemplates = {
  register: {
    subject: 'Verify Your Account',
    template: registerOtpTemplate,
  },
  reset: {
    subject: 'Your Testiva Password Reset Code',
    template: resetOtpTemplate,
  },
  postFlagged: {
    subject: 'Community Post Moderation Notice',
    template: postFlaggedTemplate,
  },
  preferenceChange: {
    subject: '🚨 Testiva: Preference Change Request Received',
    template: preferenceChangeRequestTemplate,
  }
};

const sendEmail = async ({ to, subject, html }) => {
  const mailer = getTransporter();
  if (!mailer) {
    const err = new Error('SMTP credentials are not configured');
    err.code = 'SMTP_CONFIG';
    throw err;
  }
  const { user } = getSmtpCredentials();
  return mailer.sendMail({
    from: user,
    to,
    subject,
    html,
  });
};

export const sendOtpEmail = async ({ email, otp, type = 'register' }) => {
  const emailConfig = emailTemplates[type];
  if (!emailConfig) {
    throw new Error('Invalid email template type');
  }
  const html = emailConfig.template(otp);
  try {
    await sendEmail({
      to: email,
      subject: emailConfig.subject,
      html,
    });
    console.log(`[EMAIL SUCCESS] OTP email successfully sent to ${email}`);
    return { sent: true };
  } catch (error) {
    const smtpCode = error.responseCode || error.code;
    const smtpMessage = String(error.message || "");
    const gmailRejectedPass = isSmtpAuthFailure(error);
    if (gmailRejectedPass && (Number(smtpCode) === 535 || smtpMessage.includes('535') || error.code === 'EAUTH')) {
      console.error(
        "OTP email failed: Gmail rejected EMAIL_PASS (535). Update Backend/.env EMAIL_PASS with a new App Password and restart.",
      );
    } else if (error.code === "SMTP_CONFIG") {
      console.error(
        "[EMAIL] Missing SMTP credentials. Set EMAIL_USER and EMAIL_PASS in Backend/.env and restart.",
      );
    } else {
      console.error(
        `[EMAIL ERROR] Failed to send OTP email to ${email}:`,
        error.message,
      );
    }

    if (gmailRejectedPass && isDevOtpFallbackEnabled()) {
      console.warn(
        `[EMAIL] SMTP failed for ${email}; returning DEV OTP because ALLOW_DEV_OTP=true. Fix EMAIL_PASS (Gmail App Password) for real delivery.`,
      );
      console.log(`DEV OTP for ${email}: ${otp}`);
      return { sent: false, emailSent: false, devOtp: String(otp) };
    }

    // Always throw the generic student-safe message; App Password details stay in logs above.
    throw new Error(OTP_SEND_FAILED_MESSAGE);
  }
};

export const sendPostFlaggedEmail = async ({ email, userName, postTitle, adminFeedback }) => {
  const emailConfig = emailTemplates.postFlagged;
  const html = emailConfig.template({ userName, postTitle, adminFeedback, });
  await sendEmail({
    to: email,
    subject: emailConfig.subject,
    html,
  });
};

export const sendPreferenceChangeEmail = async ({ adminEmail, userName, userEmail, currentPreference, targetPreference, feedback }) => {
  const emailConfig = emailTemplates.preferenceChange;
  const html = emailConfig.template({ userName, userEmail, currentPreference, targetPreference, feedback });
  await sendEmail({
    to: adminEmail,
    subject: `${emailConfig.subject} - ${userName}`,
    html,
  });
};
