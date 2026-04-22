import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import '../../dashboard/dashboard_screen.dart';
import 'social_login_btns.dart';
import '../../auth/forgot_password/forgot_password_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _showDemo = false;
  bool _canLogin = false; // Button enable/disable ke liye

  @override
  void initState() {
    super.initState();
    // Dono fields par listeners laga diye taake typing check ho
    _email.addListener(_validate);
    _pass.addListener(_validate);
  }

  void _validate() {
    setState(() {
      // Basic validation: email mein @ ho aur password 6 letters se bara ho
      _canLogin = _email.text.contains('@') && _pass.text.length >= 6;
    });
  }

  void _fill(String e, String p) => setState(() {
    _email.text = e;
    _pass.text = p;
  });

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label("Email Address"),
      _buildField('Enter your email', Icons.email_outlined, controller: _email),
      const SizedBox(height: 20),
      _label("Password"),
      _buildField('Enter your password', Icons.lock_outline, isPass: true, controller: _pass),

      // Forgot Password Navigation Update
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()),
            );
          },
          child: const Text('Forgot Password?',
              style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.w600)),
        ),
      ),

      SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Login',
          // Agar validation fail hai to null pass hoga (Button grey ho jayega)
          onPressed: _canLogin
              ? () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const DashboardScreen()),
          )
              : null,
        ),
      ),
      const SizedBox(height: 20),
      const SocialLoginBtns(),
      Center(
        child: TextButton.icon(
          onPressed: () => setState(() => _showDemo = !_showDemo),
          icon: Icon(_showDemo ? Icons.visibility_off : Icons.visibility,
              size: 18, color: Colors.grey),
          label: Text("${_showDemo ? 'Hide' : 'Show'} Demo Credentials",
              style: const TextStyle(color: Colors.grey)),
        ),
      ),
      if (_showDemo) _demoBox(),
    ]);
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));

  Widget _demoBox() => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100)),
    child: Column(children: [
      _demoTile("Free User", "freeuser@example.com", Icons.person_outline,
          Colors.blue),
      _demoTile("Premium", "premiumuser@example.com", Icons.star_outline,
          Colors.orange),
    ]),
  );

  Widget _demoTile(String l, String e, IconData i, Color c) => GestureDetector(
    onTap: () => _fill(e, "password123"),
    child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(i, size: 16, color: c),
          const SizedBox(width: 8),
          Text("$l: $e",
              style: TextStyle(fontSize: 12, color: Colors.blue[900]))
        ])),
  );

  Widget _buildField(String h, IconData i,
      {bool isPass = false, required TextEditingController controller}) =>
      TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: h,
          prefixIcon: Icon(i, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF007BFF))),
        ),
      );
}