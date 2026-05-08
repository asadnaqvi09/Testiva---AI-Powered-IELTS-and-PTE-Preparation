import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/src/auth/login/widgets/google_button.dart';

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
            label: 'Full Name',
            hint: 'e.g. Ahmed Khan',
            prefixIcon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            validator: AppValidators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: _passController,
            validator: AppValidators.validatePassword,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: _confirmPassController,
            validator: (val) {
              if (val != _passController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 25),
          AppButton(
            text: 'Create Account',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Signup Logic
              }
            },
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