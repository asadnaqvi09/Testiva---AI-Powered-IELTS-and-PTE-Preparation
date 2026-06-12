import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({required this.email, super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (i) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (i) => FocusNode());

  bool _isLoading = false;
  bool _isExpired = false;

  int _secondsRemaining = 50;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 50;
      _isExpired = false;
      for (var c in _controllers) { c.clear(); }
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() {
          _isExpired = true;
        });
        _timer?.cancel();
      }
    });
  }

  String _getFormattedTime() {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _maskEmail(String email) {
    try {
      final parts = email.split('@');
      if (parts[0].length <= 2) return email;
      return '${parts[0].substring(0, 2)}***********@${parts[1]}';
    } catch (e) {
      return email;
    }
  }

  // 🔄 Resend OTP API Call Linked with Server Route
  Future<void> _handleResendOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('/auth/resend-otp', {
        'email': widget.email,
        'type': 'register',
      });

      final responseData = jsonDecode(response.body);

      if (mounted) {
        if (response.statusCode == 200 && responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A fresh OTP has been sent!'), backgroundColor: Colors.green),
          );
          _startTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to resend OTP'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🚀 Live Email Verification API Call
  Future<void> _handleVerifyOtp() async {
    if (_isExpired) return;

    String otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // FIX: Gateway route map kiya backend engine ke mutabiq
      final response = await ApiService.post('/auth/verify-otp', {
        'email': widget.email,
        'otp': otpCode,
        'type': 'register',
      });

      if (mounted) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['success'] == true) {
          // Senior Touch: Token received ho gaya, isay globally state mein inject kar dein
          if (responseData['accessToken'] != null) {
            ApiService.setToken(responseData['accessToken']);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account Verified Successfully! Welcome to Testiva.'), backgroundColor: Colors.green),
          );

          // Account verify ho gya aur session token save hai, ab seedha dashboard screen par push kar dein
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Invalid OTP code'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillDemoOtp() {
    if (_isExpired) return;
    const demoOtp = '1234';
    for (int i = 0; i < 4; i++) {
      _controllers[i].text = demoOtp[i];
    }
    FocusScope.of(context).requestFocus(_focusNodes[3]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Testiva App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isExpired ? Colors.red[50] : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  _isExpired ? Icons.access_time_filled : Icons.verified_user,
                  size: 50,
                  color: _isExpired ? Colors.red : AppColors.primary
              ),
            ),
            const SizedBox(height: 24),

            if (!_isExpired) ...[
              const Text(
                'Verify Your Email ✉️',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: "We've sent a 4-digit verification code to\n"),
                    const WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.only(right: 5, top: 2),
                        child: Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
                      ),
                    ),
                    TextSpan(
                      text: _maskEmail(widget.email),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'OTP Expired ⏰',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your OTP has expired. Request a new one to\ncontinue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD9D9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verification Code Expired',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The OTP sent to your email is no longer valid. Click "Resend OTP" below to get a fresh code.',
                            style: TextStyle(color: Colors.red[900], fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            if (!_isExpired) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Code expires in', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    _getFormattedTime(),
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _secondsRemaining / 50,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 30),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildOtpBox(index)),
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _isExpired
                ? AppButton(
              text: 'Resend OTP',
              onPressed: _handleResendOtp,
            )
                : AppButton(
              text: 'Verify OTP',
              onPressed: _handleVerifyOtp,
            ),
            const SizedBox(height: 25),

            if (_isExpired) ...[
              _buildInfoCard(Icons.mail_outline, 'Check your spam/junk folder', 'Sometimes OTP emails land in spam. Check all folders before resending.'),
              const SizedBox(height: 12),
              _buildInfoCard(Icons.access_time, 'OTP valid for 15 minutes', 'Each code expires after backend countdown session. Enter it quickly.'),
              const SizedBox(height: 25),
            ],

            if (!_isExpired) ...[
              GestureDetector(
                onTap: _fillDemoOtp,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE599)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 13, color: Colors.black),
                            children: [
                              TextSpan(text: 'Demo OTP: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '1 2 3 4 ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                              TextSpan(text: '(prototype verification matches backend)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(
                    onPressed: null,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: Text(
                      'Resend in ${_secondsRemaining}s',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '← Back to Register',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 56,
      height: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: !_isExpired,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _isExpired ? Colors.grey : Colors.black),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _isExpired ? Colors.grey[100] : Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}