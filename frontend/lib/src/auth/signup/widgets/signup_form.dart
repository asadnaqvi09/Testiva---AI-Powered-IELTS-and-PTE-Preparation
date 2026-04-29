import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/widgets/app_button.dart';
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
          _label("Full Name"),
          _buildTextField("e.g. Ahmed Khan", Icons.person_outline, controller: _nameController),
          const SizedBox(height: 16),
          _label("Email Address"),
          _buildTextField("Enter your email", Icons.email_outlined, controller: _emailController, validator: AppValidators.validateEmail),
          const SizedBox(height: 16),
          _label("Password"),
          _buildTextField("Enter your password", Icons.lock_outline, isPass: true, controller: _passController, validator: AppValidators.validatePassword),
          const SizedBox(height: 16),
          _label("Confirm Password"),
          _buildTextField(
            "Confirm your password",
            Icons.lock_outline,
            isPass: true,
            controller: _confirmPassController,
            validator: (val) {
              if (val != _passController.text) return "Passwords do not match";
              return null;
            },
          ),
          const SizedBox(height: 25),
          AppButton(
            text: "Create Account",
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
                  child: Text("or continue with", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _buildTextField(String hint, IconData icon, {bool isPass = false, required TextEditingController controller, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
        suffixIcon: isPass ? Icon(Icons.visibility_outlined, color: AppColors.textGrey, size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}