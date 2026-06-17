import 'package:flutter/material.dart';
import '../../../../core/services/google_auth_service.dart';
import 'google_button.dart';

class SocialLoginBtns extends StatelessWidget {
  const SocialLoginBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GoogleButton(
            onTap: () => GoogleAuthService.handleGoogleSignIn(context),
          ),
        ),
      ],
    );
  }
}