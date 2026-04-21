lib/src/auth/
├── auth_screen.dart             (Main Parent Screen jo Login/Signup ko hold karti hai)
├── login/                       (Login Feature)
│   ├── login_page.dart          (Login ki main UI file)
│   └── widgets/
│       ├── auth_toggle.dart     (Login/Signup switcher)
│       ├── google_button.dart
│       ├── login_form.dart      (TextFields + Forgot Password Sheet)
│       ├── login_header.dart
│       └── social_login_btns.dart
├── signup/                      (Signup Feature)
│   ├── signup_page.dart
│   └── widgets/
│       └── signup_form.dart     (Register button -> OTP Trigger)
├── forgot_password/             (Naya Folder for Recovery)
│   ├── otp_screen.dart          (Verification + Timer + Resend)
│   └── reset_password_screen.dart (New Password entry)
└── onboarding/                  (Welcome Screens)
├── onboarding_screen.dart
└── widgets/
├── onboarding_header.dart
└── onboarding_stats.dart