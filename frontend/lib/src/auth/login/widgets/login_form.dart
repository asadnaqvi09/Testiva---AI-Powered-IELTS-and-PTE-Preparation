import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/auth_navigation_helper.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/src/auth/forgot_password/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPass = prefs.getString('saved_password') ?? '';

    if (savedEmail.isNotEmpty && savedPass.isNotEmpty) {
      setState(() {
        _email.text = savedEmail;
        _pass.text = savedPass;
        _rememberMe = true;
      });
    }
  }

  void _fill(String e, String p) => setState(() {
    _email.text = e;
    _pass.text = p;
  });

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final emailStr = _email.text.trim().toLowerCase();
      final passStr = _pass.text;

      final response = await ApiService.post('/auth/login', {
        'email': emailStr,
        'password': passStr,
      });

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = jsonDecode(response.body);

          if (resData['accessToken'] != null) {
            await ApiService.setToken(resData['accessToken'].toString());
          } else if (resData['data'] != null && resData['data']['token'] != null) {
            await ApiService.setToken(resData['data']['token'].toString());
          } else if (resData['token'] != null) {
            await ApiService.setToken(resData['token'].toString());
          }

          final prefs = await SharedPreferences.getInstance();
          if (_rememberMe) {
            await prefs.setString('saved_email', emailStr);
            await prefs.setString('saved_password', passStr);
          } else {
            await prefs.remove('saved_email');
            await prefs.remove('saved_password');
          }

          final user = Map<String, dynamic>.from(
            (resData['user'] as Map<String, dynamic>?) ?? {},
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
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'] ?? 'Login failed'),
              backgroundColor:
                  response.statusCode == 409 ? Colors.orange : null,
            ),
          );
        }
      }
    } catch (e) {
      print('Login Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error: Unable to connect to server')),
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
              _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textGrey,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember Me',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
            TextButton(
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
          ],
        ),
        const SizedBox(height: 10),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AppButton(
          text: 'Login',
          onPressed: _handleLogin,
        ),
        const SizedBox(height: 20),
        const SocialLoginBtns(),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _showDemo = !_showDemo),
            icon: Icon(_showDemo ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textGrey),
            label: Text('${_showDemo ? 'Hide' : 'Show'} Demo Credentials', style: const TextStyle(color: AppColors.textGrey)),
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
      _demoTile('Free User', 's23-0385@student.uoh.pk', Icons.person_outline, AppColors.primary),
      _demoTile('Premium', 'premiumuser@example.com', Icons.star_outline, Colors.orange),
    ]),
  );

  Widget _demoTile(String l, String e, IconData i, Color c) => GestureDetector(
    onTap: () => _fill(e, 'aksa12345@sk'),
    child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(i, size: 16, color: c),
          const SizedBox(width: 8),
          Text('$l: $e', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
        ])),
  );
}