import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import 'widgets/onboarding_header.dart'; // Import kiya
import 'widgets/onboarding_stats.dart';  // Import kiya

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> contents = [
    {"title": "Personalized Learning", "desc": "AI-powered study plans...", "icon": Icons.psychology_outlined},
    {"title": "AI-Powered Mocks", "desc": "Practice with realistic...", "icon": Icons.bolt_outlined},
    {"title": "Start Free Today", "desc": "Join 50,000+ students...", "icon": Icons.verified_user_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OnboardingHeader(), // Chota sa Widget call
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: contents.length,
                itemBuilder: (ctx, i) => _buildPageContent(i),
              ),
            ),
            _buildDots(),
            const OnboardingStats(), // Chota sa Widget call
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  // Choty helpers screen ke neechay hi rehne den ya inka bhi alag widget bana len
  Widget _buildPageContent(int i) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 140, width: 140,
          decoration: BoxDecoration(color: const Color(0xFFF0F7FF), borderRadius: BorderRadius.circular(25)),
          child: Icon(contents[i]['icon'], size: 70, color: const Color(0xFF007BFF)),
        ),
        const SizedBox(height: 40),
        Text(contents[i]['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(contents[i]['desc'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          AppButton(text: "Get Started", onPressed: () {}),
          TextButton(onPressed: () {}, child: const Text("Continue as Guest", style: TextStyle(color: Color(0xFF007BFF)))),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(contents.length, (index) => Container(
        height: 6, width: _currentIndex == index ? 24 : 6,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _currentIndex == index ? Colors.blue : Colors.blue[100]),
      )),
    );
  }
}