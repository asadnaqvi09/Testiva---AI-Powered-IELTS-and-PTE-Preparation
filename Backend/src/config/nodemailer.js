import nodemailer from "nodemailer";

const htmlTemp = (otp) => `
  <div style="font-family:Arial;padding:20px;background:#f5f7ff">
  <div style="max-width:420px;margin:auto;background:#fff;padding:30px;border-radius:12px;text-align:center">
    <h2 style="color:#4f46e5">Verify Your Account</h2>
    <p style="color:#555">Use the OTP below to complete registration</p>
    <div style="font-size:28px;letter-spacing:8px;font-weight:bold;margin:20px 0;color:#111">
      {{OTP}}
    </div>
    <p style="color:#888;font-size:12px">
      This code will expire in 15 minutes
    </p>
    <hr />
    <p style="font-size:11px;color:#aaa">
      If you didn't request this, ignore this email
    </p>
  </div>
</div>
`;
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  },
  secure: true
});

export const sendOtpEmail = async (email, otp) => {
  await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Your OTP Code",
    html: htmlTemp(otp).replace("{{OTP}}" , otp)
  });
};