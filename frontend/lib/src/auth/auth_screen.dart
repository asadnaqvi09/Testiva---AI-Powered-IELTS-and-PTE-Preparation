import 'package:flutter/material.dart';
import 'package:frontend/widgets/brand_mark.dart';
import 'package:frontend/widgets/circle_icon_button.dart';
import 'login/widgets/login_form.dart';
import 'signup/widgets/signup_form.dart';
import 'login/widgets/login_header.dart';
import 'login/widgets/auth_toggle.dart';

class AuthScreen extends StatefulWidget {
  final bool startOnLogin;
  final bool allowBack;

  const AuthScreen({
    super.key,
    this.startOnLogin = true,
    this.allowBack = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    isLogin = widget.startOnLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
              child: Row(
                children: [
                  if (widget.allowBack) ...[
                    CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const BrandMark(markSize: 32, fontSize: 16),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoginHeader(isLogin: isLogin),
                    const SizedBox(height: 22),
                    AuthToggle(
                      isLogin: isLogin,
                      onChanged: (value) {
                        setState(() {
                          isLogin = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    isLogin ? const LoginForm() : const SignupForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
