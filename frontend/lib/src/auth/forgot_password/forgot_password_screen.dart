import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService ka path verify kar lein
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import '../../../widgets/app_button.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Senior Touch: Loading state management

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // API Call Function
  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final userEmail = _emailController.text.trim();

    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': userEmail,
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully to your email!'), backgroundColor: Colors.green),
        );
        // Successful response par OTP Screen par email pass kar ke navigation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(email: userEmail),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to send OTP'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 30),
              AppTextField(
                label: 'Email Address',
                hint: 'Email Address',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
                validator: AppValidators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const Spacer(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                  : AppButton(
                text: 'Send Reset Link',
                onPressed: _handleForgotPassword,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}