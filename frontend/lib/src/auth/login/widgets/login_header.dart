import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_typography.dart';

class LoginHeader extends StatelessWidget {
  final bool isLogin;

  const LoginHeader({super.key, this.isLogin = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLogin ? 'Welcome Back! 👋' : 'Join Testiva ✨',
          style: AppTypography.display(),
        ),
        const SizedBox(height: 8),
        Text(
          isLogin
              ? 'Sign in to continue your learning journey'
              : 'Create your free account today',
          style: AppTypography.body(color: const Color(0xFF64748B)),
        ),
      ],
    );
  }
}
