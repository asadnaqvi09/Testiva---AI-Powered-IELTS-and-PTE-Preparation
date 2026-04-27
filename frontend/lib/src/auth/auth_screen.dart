import 'package:flutter/material.dart';
import 'login/widgets/login_form.dart';
import 'signup/widgets/signup_form.dart';
import 'login/widgets/login_header.dart';
import 'login/widgets/auth_toggle.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

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
        title: const Text('Testiva', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const LoginHeader(),
              const SizedBox(height: 20),
              AuthToggle(
                isLogin: isLogin,
                onChanged: (value) {
                  setState(() {
                    isLogin = value;
                  });
                },
              ),
              const SizedBox(height: 25),
              isLogin ? const LoginForm() : const SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}