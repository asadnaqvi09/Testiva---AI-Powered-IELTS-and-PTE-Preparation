import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/auth_navigation_helper.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import '../../forgot_password/forgot_password_screen.dart';
import 'demo_credentials.dart';
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
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _showDemo = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final saved = await ApiService.loadStudentCredentials();
    if (!mounted) return;
    if (saved.email.isEmpty && saved.password.isEmpty) return;
    setState(() {
      if (saved.email.isNotEmpty) _email.text = saved.email;
      if (saved.password.isNotEmpty) _pass.text = saved.password;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please fill in all fields to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final emailStr = _email.text.trim().toLowerCase();
      final passStr = _pass.text;

      final response = await ApiService.post('/auth/login', {
        'email': emailStr,
        'password': passStr,
      });

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final resData = ApiService.parseJsonObject(response.body);
            final payload = ApiService.unwrapAuthPayload(resData);
            await ApiService.persistAuthResponse(payload);

            final user = ApiService.userFromAuthPayload(payload);
            await ApiService.saveStudentCredentials(
              email: emailStr,
              password: passStr,
              role: user['role']?.toString(),
            );
            if (user.isEmpty) {
              user['email'] = emailStr;
            }

            if (!mounted) return;

            await AuthNavigationHelper.navigateAfterAuth(
              context,
              user: user,
              successMessage: 'Welcome back!',
            );
          } catch (parseErr) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Login response error: $parseErr\n'
                  'HTTP ${response.statusCode}  Host: ${AppConfig.apiOrigin}',
                ),
                duration: const Duration(seconds: 8),
              ),
            );
          }
        } else {
          String message = 'Login failed (HTTP ${response.statusCode})';
          try {
            final errorData = jsonDecode(response.body);
            final serverMsg = errorData is Map ? errorData['message'] : null;
            if (serverMsg != null) {
              message = '$serverMsg (HTTP ${response.statusCode})';
            }
          } catch (_) {}
          setState(() => _errorMessage = message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor:
                  response.statusCode == 409 ? Colors.orange : null,
            ),
          );
        }
      }
    } catch (e) {
      print('Login Error: $e  host=${AppConfig.apiOrigin}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppConfig.formatConnectionError(e)),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
          isPassword: _obscurePass,
          controller: _pass,
          validator: AppValidators.validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textGrey,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFFB91C1C),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        AppButton(
          text: _isLoading ? 'Signing in...' : 'Login',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handleLogin,
        ),
        const SizedBox(height: 20),
        const SocialLoginBtns(),
        const SizedBox(height: 16),
        DemoCredentials(
          expanded: _showDemo,
          onToggle: () => setState(() => _showDemo = !_showDemo),
          onFill: (email, password) {
            setState(() {
              _email.text = email;
              _pass.text = password;
            });
          },
        ),
      ]),
    );
  }
}
