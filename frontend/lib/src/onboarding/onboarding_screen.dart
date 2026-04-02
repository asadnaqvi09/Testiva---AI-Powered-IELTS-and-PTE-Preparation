import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import '../login/login_screen.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/onboarding_stats.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> contents = [
    {
      "title": "Personalized Learning",
      "desc": "AI-powered study plans tailored to your\nunique strengths and learning style.",
      "icon": Icons.psychology_outlined
    },
    {
      "title": "AI-Powered Mocks",
      "desc": "Practice with realistic IELTS & PTE mock\ntests. Get instant AI feedback.",
      "icon": Icons.bolt_outlined
    },
    {
      "title": "Start Free Today",
      "desc": "Join 50,000+ students already improving\ntheir scores with Testiva.",
      "icon": Icons.verified_user_outlined
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OnboardingHeader(),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: contents.length,
                itemBuilder: (ctx, i) => _buildPageContent(i),
              ),
            ),
            _buildDots(),
            const OnboardingStats(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int i) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(25)
          ),
          child: Icon(contents[i]['icon'], size: 70, color: const Color(0xFF007BFF)),
        ),
        const SizedBox(height: 40),
        Text(contents[i]['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Text(
              contents[i]['desc'],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4)
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          AppButton(
            text: "Get Started",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          TextButton(
              onPressed: () {},
              child: const Text(
                  "Continue as Guest",
                  style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold)
              )
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(contents.length, (index) => Container(
        height: 6,
        width: _currentIndex == index ? 24 : 6,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _currentIndex == index ? const Color(0xFF007BFF) : Colors.blue[100]
        ),
      )),
    );
  }
}