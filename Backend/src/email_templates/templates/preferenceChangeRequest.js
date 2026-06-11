const escapeHtml = (value = '') =>
  value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');

export const preferenceChangeRequestTemplate = ({
  userName,
  userEmail,
  currentPreference,
  targetPreference,
  feedback,
}) => {
  const safeUserName = escapeHtml(userName);
  const safeUserEmail = escapeHtml(userEmail);
  const safeCurrent = escapeHtml(currentPreference || 'None (NULL)');
  const safeTarget = escapeHtml(targetPreference);
  const safeFeedback = escapeHtml(feedback);

  return `
<!DOCTYPE html>
<html>
  <body style="margin:0;padding:40px 16px;background:#F3F4F6;font-family:Arial,sans-serif;">
    <div style="max-width:560px;margin:0 auto;background:#FFFFFF;border-radius:12px;padding:32px;border:1px solid #E5E7EB;">
      <div style="display:flex;align-items:center;margin-bottom:28px;">
        <div style="width:44px;height:44px;border-radius:999px;background:#E0E7FF;display:flex;align-items:center;justify-content:center;margin-right:12px;">
          <span style="font-size:22px;">⚙️</span>
        </div>
        <div>
          <h2 style="margin:0;font-size:22px;color:#111827;">
            Preference Change Request
          </h2>
          <p style="margin:4px 0 0 0;color:#6B7280;font-size:14px;">
            Testiva Operational System Control
          </p>
        </div>
      </div>
      <p style="margin:0 0 16px 0;color:#374151;font-size:15px;">
        Hello Administrator,
      </p>
      <p style="margin:0 0 20px 0;color:#374151;line-height:1.7;font-size:15px;">
        User <strong style="color:#111827;">${safeUserName}</strong> (${safeUserEmail}) has requested a modification to their locked exam track platform profile parameters.
      </p>
      
      <table style="width:100%;border-collapse:collapse;margin-bottom:24px;font-size:14px;">
        <tr>
          <td style="padding:8px 0;color:#6B7280;width:40%;">Current Track:</td>
          <td style="padding:8px 0;color:#111827;font-weight:600;">${safeCurrent}</td>
        </tr>
        <tr>
          <td style="padding:8px 0;color:#6B7280;">Requested Track:</td>
          <td style="padding:8px 0;color:#4F46E5;font-weight:600;">${safeTarget}</td>
        </tr>
      </table>

      <div style="background:#F9FAFB;border-left:4px solid #4F46E5;border-radius:8px;padding:16px 18px;margin-bottom:24px;">
        <p style="margin:0 0 8px 0;color:#374151;font-weight:700;font-size:14px;">
          User's Explanation/Feedback
        </p>
        <p style="margin:0;color:#4B5563;line-height:1.7;font-size:14px;font-style:italic;">
          "${safeFeedback}"
        </p>
      </div>
      
      <div style="border-top:1px solid #E5E7EB;padding-top:18px;">
        <p style="margin:0;color:#9CA3AF;font-size:12px;line-height:1.6;">
          This is an internal structural notification dispatched directly to administrative control workflows from the profile settings container interface.
        </p>
      </div>
    </div>
  </body>
</html>
`;
};