lib/
├── main.dart
├── core/
│   ├── constants/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── src/
│   ├── auth/
│   │   ├── login/
│   │   │   └── widgets/ (login_form.dart, login_header.dart, etc.)
│   │   ├── signup/
│   │   │   └── widgets/ (signup_form.dart, etc.)
│   │   ├── forgot_password/
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── otp_screen.dart
│   │   │   └── reset_password_screen.dart
│   │   └── auth_screen.dart
│   ├── dashboard/
│   │   ├── home/
│   │   │   ├── widgets/ (header_section.dart, stats_row.dart, etc.)
│   │   │   └── home_page.dart
│   │   ├── widgets/
│   │   │   ├── custom_drawer.dart  <-- (Settings link yahan hai)
│   │   │   └── stats_card.dart
│   │   └── dashboard_screen.dart
│   ├── features/
│   │   └── settings/
│   │       └── presentation/
│   │           ├── widgets/ (rating_section.dart, category_chips.dart, etc.)
│   │           ├── settings_screen.dart
│   │           └── feedback_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   └── profile/
│       ├── widgets/ (edit_profile_modal.dart, progress_graph.dart)
│       └── profile_screen.dart
└── widgets/ (Global Widgets)
├── app_button.dart
├── custom_button.dart
├── custom_textfield.dart
└── logout_dialog.dart