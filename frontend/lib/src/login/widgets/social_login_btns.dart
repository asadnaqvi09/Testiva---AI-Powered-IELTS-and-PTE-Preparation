import 'package:flutter/material.dart';
import 'google_button.dart';

class SocialLoginBtns extends StatelessWidget {
  const SocialLoginBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoogleButton(
          onTap: () {
            print("Google Login Tapped!");
          },
        ),
      ],
    );
  }
}