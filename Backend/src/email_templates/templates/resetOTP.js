export const resetOtpTemplate = (otp) => `
<div style="font-family:Arial;padding:20px;background:#fff7f7">
  <div style="max-width:420px;margin:auto;background:#fff;padding:30px;border-radius:12px;text-align:center">
    <h2 style="color:#dc2626">Password Reset Request</h2>
    <p>Use this OTP to reset your password</p>

    <div style="font-size:28px;letter-spacing:8px;font-weight:bold;margin:20px 0;color:#111">
      ${otp}
    </div>

    <p style="font-size:12px;color:#888">
      If you didn't request this, ignore this email
    </p>
  </div>
</div>
`;