import 'package:flutter/material.dart';
import '../../../../core/services/google_auth_service.dart';
import 'google_button.dart';

class SocialLoginBtns extends StatelessWidget {
  const SocialLoginBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 14),
        GoogleButton(
          onTap: () => GoogleAuthService.handleGoogleSignIn(context),
        ),
      ],
    );
  }
}
