/// Student-safe OTP email helpers.
///
/// Never surface `devOtp`, App Password text, or SMTP technician copy in the
/// student app. When `ALLOW_DEV_OTP=true`, the API may still include `devOtp`
/// for Postman / server logs — Flutter ignores it.

const String kOtpSendFailedMessage = 'Could not send OTP. Please try again.';

/// True when the API confirms the OTP email was delivered (or omits the flag).
bool isOtpEmailSent(dynamic responseData) {
  if (responseData is! Map) return true;
  if (responseData['emailSent'] == false) return false;
  return true;
}

String otpSendSuccessMessage({String fallback = 'OTP sent to your email.'}) =>
    fallback;
