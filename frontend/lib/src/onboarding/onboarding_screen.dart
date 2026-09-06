import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import '../auth/auth_screen.dart';
import './widgets/onboarding_header.dart';
import './widgets/onboarding_stats.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Personalized Learning',
      'subtitle': 'AI study focus based on your mock performance — strengthen weak skills faster.',
    },
    {
      'title': 'AI-Powered Mocks',
      'subtitle': 'Practice with realistic IELTS & PTE mock tests. Get instant AI feedback.',
    },
    {
      'title': 'Start Free Today',
      'subtitle': 'Join 50,000+ students already improving their scores with Testiva.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoCycle();
  }

  void _startAutoCycle() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % onboardingData.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const OnboardingHeader(),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildPageContent(_currentPage),
              ),
              const SizedBox(height: 40),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    return Column(
      key: ValueKey<int>(index),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Icon(
              index == 0 ? Icons.psychology : index == 1 ? Icons.bolt_rounded : Icons.shield_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          onboardingData[index]['title']!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 20),
        Text(
          onboardingData[index]['subtitle']!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => _buildDot(index)),
        ),
        const SizedBox(height: 30),
        const OnboardingStats(),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Get Started', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}