export const registerOtpTemplate = (otp) => `
<div style="font-family:Arial;padding:20px;background:#f5f7ff">
  <div style="max-width:420px;margin:auto;background:#fff;padding:30px;border-radius:12px;text-align:center">
    <h2 style="color:#4f46e5">Verify Your Account</h2>
    <p>Complete your registration using this OTP</p>

    <div style="font-size:28px;letter-spacing:8px;font-weight:bold;margin:20px 0;color:#111">
      ${otp}
    </div>

    <p style="font-size:12px;color:#888">
      Valid for 15 minutes
    </p>
  </div>
</div>
`;