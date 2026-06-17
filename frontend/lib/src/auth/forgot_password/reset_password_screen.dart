import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService ka sahi path check kar lein
import '../../../widgets/app_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email; // FIX: Pichli screen ka error khatam karne ke liye field add kar di

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _canUpdate = false;
  bool _isLoading = false; // Senior Touch: Loader control variable

  @override
  void initState() {
    super.initState();
    _pass.addListener(_validate);
    _confirm.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _canUpdate = _pass.text.length >= 8 && _pass.text == _confirm.text;
    });
  }

  // Live Backend API Call Function
  Future<void> _updatePassword() async {
    if (!_canUpdate) return;

    setState(() => _isLoading = true);

    try {
      // Backend router mapping ke mutabiq payload bhej rahe hain
      final response = await ApiService.post('/auth/reset-password', {
        'email': widget.email,
        'new_password': _pass.text.trim(),
        'confirm_password': _confirm.text.trim(),
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset successfully! Please login.'),
              backgroundColor: Colors.green
          ),
        );

        // Sahi tarika: Password badal gaya, ab user ko seedha login page par wapas phenk dein
        Navigator.popUntil(context, (r) => r.isFirst);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ?? 'Failed to reset password'),
              backgroundColor: Colors.red
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Connection error: ${e.toString()}'),
            backgroundColor: Colors.red
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('New Password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Set your new password to login', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          _field('New Password', Icons.lock_outline, _pass, true),
          const SizedBox(height: 20),
          _field('Confirm Password', Icons.lock_reset, _confirm, false),
          const Spacer(),
          SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                  : AppButton(
                text: 'Update Password',
                // Button disable logic barkarar hai aur click par API function map kar diya
                onPressed: _canUpdate ? _updatePassword : null,
              )
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _field(String h, IconData i, TextEditingController c, bool auto) => TextField(
    controller: c,
    obscureText: true,
    autofocus: auto,
    decoration: InputDecoration(
      hintText: h,
      prefixIcon: Icon(i, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF007BFF))),
    ),
  );
}