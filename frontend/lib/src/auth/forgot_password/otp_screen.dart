import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import '../../../widgets/app_button.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  const OTPScreen({super.key, required this.email});
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int _sec = 60;
  Timer? _t;
  final _ctrls = List.generate(4, (_) => TextEditingController());
  bool _isComplete = false;
  bool _isLoading = false; // Senior Touch: Loading overlay

  @override
  void initState() {
    super.initState();
    _startT();
  }

  void _startT() {
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sec > 0) {
        setState(() => _sec--);
      } else {
        _t?.cancel();
      }
    });
  }

  void _checkComplete() {
    setState(() {
      _isComplete = _ctrls.every((c) => c.text.isNotEmpty);
    });
  }

  // OTP Verification API Call
  Future<void> _verifyOTP() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    // Charon boxes se 4-digit code single string mein assemble karna
    String otpCode = _ctrls.map((c) => c.text).join();

    try {
      final response = await ApiService.post('/auth/verify-otp', {
        'email': widget.email,
        'otp': otpCode,
        'type': 'reset',
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verified Successfully!'), backgroundColor: Colors.green),
        );

        // Navigation to Reset Password Screen (Passing email for the next step)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(email: widget.email)
            )
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Invalid OTP code'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Resend OTP API Call
  Future<void> _resendOTP() async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': widget.email,
      });
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new OTP has been sent to your email.'), backgroundColor: Colors.green),
        );
        setState(() {
          _sec = 60;
        });
        _startT();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to resend OTP'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    for (var c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Verification Code', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Sent to ${widget.email}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (i) => _box(i))),
          const SizedBox(height: 30),
          Center(child: Text("00:${_sec.toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF007BFF)))),
          Center(
              child: TextButton(
                  onPressed: _sec == 0 ? _resendOTP : null,
                  child: Text('Resend Code', style: TextStyle(color: _sec == 0 ? const Color(0xFF007BFF) : Colors.grey))
              )
          ),
          const Spacer(),
          SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                  : AppButton(
                text: 'Verify',
                onPressed: _isComplete ? _verifyOTP : null,
              )
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _box(int i) => SizedBox(
    width: 65, height: 65,
    child: TextField(
      controller: _ctrls[i],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      autofocus: i == 0,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(counterText: '', filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2))),
      onChanged: (v) {
        if (v.isNotEmpty && i < 3) FocusScope.of(context).nextFocus();
        if (v.isEmpty && i > 0) FocusScope.of(context).previousFocus();
        _checkComplete();
      },
    ),
  );
}