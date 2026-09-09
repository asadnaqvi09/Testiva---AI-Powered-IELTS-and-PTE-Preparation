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

  final List<Map<String, dynamic>> onboardingData = [
    {
      'title': 'Personalized Learning',
      'subtitle': 'AI-powered study plans tailored to your unique strengths and learning style.',
      'icon': Icons.psychology_outlined,
      'iconColor': const Color(0xFF007BFF),
      'boxColor': const Color(0xFFE8F2FF),
      'dotColor': const Color(0xFF007BFF),
    },
    {
      'title': 'AI-Powered Mocks',
      'subtitle': 'Practice with realistic IELTS & PTE mock tests. Get instant AI feedback on your answers.',
      'icon': Icons.bolt_rounded,
      'iconColor': const Color(0xFFE6A022),
      'boxColor': const Color(0xFFFFF6E5),
      'dotColor': const Color(0xFFE6A022),
    },
    {
      'title': 'Start Free Today',
      'subtitle': 'Join 50,000+ students already improving their scores with Testiva. No credit card needed.',
      'icon': Icons.emoji_events_outlined,
      'iconColor': const Color(0xFF2E7D32),
      'boxColor': const Color(0xFFE8F5E9),
      'dotColor': const Color(0xFF43A047),
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

  void _goToAuth({bool startOnLogin = true}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(startOnLogin: startOnLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const OnboardingHeader(),
              const SizedBox(height: 28),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildPageContent(_currentPage),
                ),
              ),
              _buildBottomSection(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    final page = onboardingData[index];
    return Column(
      key: ValueKey<int>(index),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 168,
          width: 168,
          decoration: BoxDecoration(
            color: page['boxColor'] as Color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            page['icon'] as IconData,
            size: 78,
            color: page['iconColor'] as Color,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          page['title'] as String,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          page['subtitle'] as String,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    final activeColor = onboardingData[_currentPage]['dotColor'] as Color;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => _buildDot(index, activeColor)),
        ),
        const SizedBox(height: 22),
        const OnboardingStats(),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _goToAuth(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => _goToAuth(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0xFF93C5FD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Continue as Guest (Limited Access)',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, Color activeColor) {
    final active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: active ? 24 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? activeColor : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
