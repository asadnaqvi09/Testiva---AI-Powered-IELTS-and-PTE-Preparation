import nodemailer from 'nodemailer';
import { registerOtpTemplate } from './templates/registerOtp.js';
import { resetOtpTemplate } from './templates/resetOtp.js';
import { postFlaggedTemplate } from './templates/postFlagged.js';
import { preferenceChangeRequestTemplate } from './templates/preferenceChangeRequest.js';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const emailTemplates = {
  register: {
    subject: 'Verify Your Account',
    template: registerOtpTemplate,
  },
  reset: {
    subject: 'Password Reset OTP',
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
  return transporter.sendMail({
    from: process.env.EMAIL_USER,
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
  await sendEmail({
    to: email,
    subject: emailConfig.subject,
    html,
  });
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