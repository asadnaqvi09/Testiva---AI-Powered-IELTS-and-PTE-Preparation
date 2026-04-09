import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import 'social_login_btns.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildTextField("Enter your email", Icons.email_outlined, controller: _emailController),

        const SizedBox(height: 20),
        const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildTextField("Enter your password", Icons.lock_outline, isPassword: true, controller: _passwordController),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF007BFF))),
          ),
        ),

        const SizedBox(height: 10),
        AppButton(text: "Login", onPressed: () {}),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 25),
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

        const SocialLoginBtns(),

        const SizedBox(height: 30),
        _buildDemoBox(),
      ],
    );
  }

  Widget _buildDemoBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text("Demo Credentials (tap to fill)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _fillCredentials("freeuser@example.com", "password123"),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text("Free User: freeuser@example.com", style: TextStyle(fontSize: 12, color: Colors.blue[900])),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _fillCredentials("premiumuser@example.com", "premium123"),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.star_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text("Premium: premiumuser@example.com", style: TextStyle(fontSize: 12, color: Colors.blue[900])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, color: Colors.grey, size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}