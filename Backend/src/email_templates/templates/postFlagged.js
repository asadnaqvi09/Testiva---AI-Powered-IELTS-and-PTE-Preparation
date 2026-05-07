import { DEFAULT_MODERATION_REASON } from '../../utils/email.moderation.js'
const escapeHtml = (value = '') =>
  value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
export const postFlaggedTemplate = ({
  userName,
  postTitle,
  adminFeedback,
}) => {
  const reason = adminFeedback?.trim() || DEFAULT_MODERATION_REASON;
  const safeUserName = escapeHtml(userName);
  const safePostTitle = escapeHtml(postTitle);
  const safeReason = escapeHtml(reason);

  return `
<!DOCTYPE html>
<html>
  <body style="margin:0;padding:40px 16px;background:#F3F4F6;font-family:Arial,sans-serif;">
    <div style="max-width:560px;margin:0 auto;background:#FFFFFF;border-radius:12px;padding:32px;border:1px solid #E5E7EB;">
      <div style="display:flex;align-items:center;margin-bottom:28px;">
        <div style="width:44px;height:44px;border-radius:999px;background:#FEE2E2;display:flex;align-items:center;justify-content:center;margin-right:12px;">
          <span style="font-size:22px;">🚩</span>
        </div>
        <div>
          <h2 style="margin:0;font-size:22px;color:#111827;">
            Community Moderation Notice
          </h2>
          <p style="margin:4px 0 0 0;color:#6B7280;font-size:14px;">
            Test Prep Community Team
          </p>
        </div>
      </div>
      <p style="margin:0 0 12px 0;color:#374151;font-size:15px;">
        Hi <strong>${safeUserName}</strong>,
      </p>
      <p style="margin:0 0 20px 0;color:#374151;line-height:1.7;font-size:15px;">
        Your community post titled
        <strong style="color:#111827;">"${safePostTitle}"</strong>
        was reviewed by our moderation team and has been removed from the community feed.
      </p>
      <div style="background:#FEF2F2;border-left:4px solid #EF4444;border-radius:8px;padding:16px 18px;margin-bottom:24px;">
        <p style="margin:0 0 8px 0;color:#991B1B;font-weight:700;font-size:14px;">
          Moderation Reason
        </p>
        <p style="margin:0;color:#7F1D1D;line-height:1.7;font-size:14px;">
          ${safeReason}
        </p>
      </div>
      <p style="margin:0 0 24px 0;color:#4B5563;line-height:1.7;font-size:14px;">
        Please review our community guidelines before posting again. Repeated violations may lead to temporary community restrictions.
      </p>
      <a
        href="${process.env.CLIENT_URL}/community-guidelines"
        style="display:inline-block;padding:12px 18px;background:#4F46E5;color:#FFFFFF;text-decoration:none;border-radius:8px;font-size:14px;font-weight:600;margin-bottom:28px;"
      >
        View Community Guidelines
      </a>
      <div style="border-top:1px solid #E5E7EB;padding-top:18px;">
        <p style="margin:0;color:#9CA3AF;font-size:12px;line-height:1.6;">
          This is an automated moderation notification from Testiva.
          Please do not reply to this email.
        </p>
      </div>
    </div>
  </body>
</html>
`;
};