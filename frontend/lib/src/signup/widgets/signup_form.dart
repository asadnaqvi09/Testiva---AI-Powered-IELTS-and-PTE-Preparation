import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import '../../login/widgets/google_button.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Full Name"),
        _buildTextField("e.g. Ahmed Khan", Icons.person_outline),

        const SizedBox(height: 16),
        _label("Email Address"),
        _buildTextField("Enter your email", Icons.email_outlined),

        const SizedBox(height: 16),
        _label("Password"),
        _buildTextField("Enter your password", Icons.lock_outline, isPass: true),

        const SizedBox(height: 16),
        _label("Confirm Password"),
        _buildTextField("Confirm your password", Icons.lock_outline, isPass: true),

        const SizedBox(height: 25),
        AppButton(text: "Create Account", onPressed: () {}),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("or continue with", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),

        Center(
          child: GoogleButton(onTap: () {}),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _buildTextField(String hint, IconData icon, {bool isPass = false}) {
    return TextField(
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: isPass ? const Icon(Icons.visibility_outlined, color: Colors.grey, size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}