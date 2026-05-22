import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/src/auth/login/widgets/google_button.dart';
import '../otp_screen.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('/auth/register', {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passController.text,
        'confirm_password': _confirmPassController.text,
      });

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful! Code sent.')),
          );

          // Clear text fields before moving
          final enteredEmail = _emailController.text.trim().toLowerCase();
          _nameController.clear();
          _emailController.clear();
          _passController.clear();
          _confirmPassController.clear();


          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => OtpScreen(email: enteredEmail),
            ),
          );
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['message'] ?? 'Signup failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error: Server configuration failure')),
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
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'e.g. Ahmed Khan',
            prefixIcon: Icons.person_outline,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Full name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            validator: AppValidators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: _obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textGrey,
              ),
              onPressed: () {
                setState(() => _obscurePass = !_obscurePass);
              },
            ),
            validator: AppValidators.validatePassword,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirmPassController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            prefixIcon: Icons.lock_outline,
            isPassword: _obscureConfirmPass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textGrey,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPass = !_obscureConfirmPass);
              },
            ),
            validator: (val) {
              if (val != _passController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 25),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : AppButton(
            text: 'Create Account',
            onPressed: _handleSignup,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          Center(child: GoogleButton(onTap: () {})),
        ],
      ),
    );
  }
}