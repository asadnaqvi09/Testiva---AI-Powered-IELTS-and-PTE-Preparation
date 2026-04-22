import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _canUpdate = false;

  @override
  void initState() {
    super.initState();
    _pass.addListener(_validate);
    _confirm.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _canUpdate = _pass.text.length >= 6 && _pass.text == _confirm.text;
    });
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
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("New Password", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Set your new password to login", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          _field("New Password", Icons.lock_outline, _pass, true),
          const SizedBox(height: 20),
          _field("Confirm Password", Icons.lock_reset, _confirm, false),
          const Spacer(),
          SizedBox(
              width: double.infinity,
              child: AppButton(
                text: "Update Password",
                onPressed: _canUpdate ? () => Navigator.popUntil(context, (r) => r.isFirst) : null,
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