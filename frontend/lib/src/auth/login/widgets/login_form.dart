import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/src/dashboard/dashboard_screen.dart';
import 'package:frontend/src/auth/forgot_password/forgot_password_screen.dart';
import 'social_login_btns.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _showDemo = false;

  void _fill(String e, String p) => setState(() {
    _email.text = e;
    _pass.text = p;
  });

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          controller: _email,
          validator: AppValidators.validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          controller: _pass,
          validator: AppValidators.validatePassword,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        AppButton(
          text: 'Login',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const DashboardScreen()),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        const SocialLoginBtns(),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _showDemo = !_showDemo),
            icon: Icon(_showDemo ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textGrey),
            label: Text("${_showDemo ? 'Hide' : 'Show'} Demo Credentials", style: const TextStyle(color: AppColors.textGrey)),
          ),
        ),
        if (_showDemo) _demoBox(),
      ]),
    );
  }

  Widget _demoBox() => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Column(children: [
      _demoTile('Free User', 'freeuser@example.com', Icons.person_outline, AppColors.primary),
      _demoTile('Premium', 'premiumuser@example.com', Icons.star_outline, Colors.orange),
    ]),
  );

  Widget _demoTile(String l, String e, IconData i, Color c) => GestureDetector(
    onTap: () => _fill(e, 'password123'),
    child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(i, size: 16, color: c),
          const SizedBox(width: 8),
          Text('$l: $e', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
        ])),
  );
}