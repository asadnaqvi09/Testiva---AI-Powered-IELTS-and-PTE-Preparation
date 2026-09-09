import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Debug/FYP only: surface the OTP when Gmail SMTP is down.
/// Never shown in release builds (`kReleaseMode`).
void showDevOtpSnackBar(BuildContext context, dynamic responseData) {
  if (kReleaseMode) return;
  if (responseData is! Map) return;
  final raw = responseData['devOtp'];
  if (raw == null) return;
  final code = raw.toString().trim();
  if (code.isEmpty) return;
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('DEV OTP: $code'),
      duration: const Duration(seconds: 12),
      backgroundColor: const Color(0xFFE65100),
    ),
  );
}
