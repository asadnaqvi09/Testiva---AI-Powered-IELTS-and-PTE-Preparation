import nodemailer from "nodemailer";
import { registerOtpTemplate } from "./templates/registerOtp.js";
import { resetOtpTemplate } from "./templates/resetOtp.js";

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

const templates = {
  register: registerOtpTemplate,
  reset: resetOtpTemplate
};

export const sendOtpEmail = async (email, otp, type = "register") => {
  const templateFn = templates[type];

  if (!templateFn) {
    throw new Error("Invalid email template type");
  }

  const html = templateFn(otp);

  await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to: email,
    subject:
      type === "reset"
        ? "Password Reset OTP"
        : "Verify Your Account",
    html
  });
};