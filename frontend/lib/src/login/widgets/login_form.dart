import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import '../../auth/forgot_password/otp_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import 'social_login_btns.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController(), _pass = TextEditingController(), _resetEmail = TextEditingController();
  bool _showDemo = false;

  void _fill(String e, String p) => setState(() { _email.text = e; _pass.text = p; });

  void _showResetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Reset Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Enter your email to receive a reset link", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildField("Your email address", Icons.email_outlined, controller: _resetEmail),
          const SizedBox(height: 25),
          Row(children: [
            Expanded(child: _sheetBtn("Cancel", () => Navigator.pop(ctx), isGrey: true)),
            const SizedBox(width: 15),
            Expanded(child: _sheetBtn("Send Reset Link", () {
              String email = _resetEmail.text.trim();
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (c) => OTPScreen(email: email.isEmpty ? "user@example.com" : email)));
            })),
          ]),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _sheetBtn(String txt, VoidCallback tap, {bool isGrey = false}) => TextButton(
    onPressed: tap,
    style: TextButton.styleFrom(
      backgroundColor: isGrey ? const Color(0xFFF8F9FA) : const Color(0xFF007BFF),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Text(txt, style: TextStyle(color: isGrey ? Colors.black87 : Colors.white)),
  );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label("Email Address"),
      _buildField('Enter your email', Icons.email_outlined, controller: _email),
      const SizedBox(height: 20),
      _label("Password"),
      _buildField('Enter your password', Icons.lock_outline, isPass: true, controller: _pass),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _showResetSheet, child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF007BFF))))),
      SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Login',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => DashboardScreen()),
          ),
        ),
      ),
      const SizedBox(height: 20),
      const SocialLoginBtns(),
      Center(child: TextButton.icon(onPressed: () => setState(() => _showDemo = !_showDemo), icon: Icon(_showDemo ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey), label: Text("${_showDemo ? 'Hide' : 'Show'} Demo Credentials", style: const TextStyle(color: Colors.grey)))),
      if (_showDemo) _demoBox(),
    ]);
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));

  Widget _demoBox() => Container(
    margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade100)),
    child: Column(children: [
      _demoTile("Free User", "freeuser@example.com", Icons.person_outline, Colors.blue),
      _demoTile("Premium", "premiumuser@example.com", Icons.star_outline, Colors.orange),
    ]),
  );

  Widget _demoTile(String l, String e, IconData i, Color c) => GestureDetector(
    onTap: () => _fill(e, "password123"),
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Icon(i, size: 16, color: c), const SizedBox(width: 8), Text("$l: $e", style: TextStyle(fontSize: 12, color: Colors.blue[900]))])),
  );

  Widget _buildField(String h, IconData i, {bool isPass = false, required TextEditingController controller}) => TextField(
    controller: controller, obscureText: isPass,
    decoration: InputDecoration(hintText: h, prefixIcon: Icon(i, color: Colors.grey), filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
  );
}