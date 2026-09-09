import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/utils/dev_otp.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final userEmail = _emailController.text.trim().toLowerCase();

    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': userEmail,
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseData['success'] == true &&
          isOtpEmailSent(responseData)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otpSendSuccessMessage(
              fallback: 'OTP sent to your Gmail. Check your inbox.',
            )),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(email: userEmail),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] is String &&
                      (responseData['message'] as String).isNotEmpty &&
                      !(responseData['message'] as String)
                          .toLowerCase()
                          .contains('app password') &&
                      !(responseData['message'] as String)
                          .toLowerCase()
                          .contains('dev otp')
                  ? responseData['message']
                  : kOtpSendFailedMessage,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(kOtpSendFailedMessage),
          backgroundColor: Colors.red,
        ),
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
                'Forgot Password?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter the Gmail you signed up with. We'll send a 4-digit OTP there. After you verify it, you'll set a new password — because you no longer know the old one.",
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
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
                text: 'Send OTP',
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
