import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';
import '../auth/auth_screen.dart';
import './widgets/onboarding_header.dart';
import './widgets/onboarding_stats.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color wash;
  final Color iconColor;
  final Color accent;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.wash,
    required this.iconColor,
    required this.accent,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  Timer? _timer;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Personalized Learning',
      subtitle:
          'AI-powered study plans tailored to your unique strengths and learning style.',
      icon: Icons.menu_book_outlined,
      wash: Color(0xFFEFF6FF),
      iconColor: AppColors.primary,
      accent: AppColors.primary,
    ),
    _OnboardingSlide(
      title: 'AI Powered Mocks',
      subtitle:
          'Practice with realistic IELTS & PTE mock tests. Get instant AI feedback.',
      icon: Icons.quiz_outlined,
      wash: Color(0xFFEEF2FF),
      iconColor: Color(0xFF4F46E5),
      accent: Color(0xFF4F46E5),
    ),
    _OnboardingSlide(
      title: 'Start Free Today',
      subtitle:
          'Join 50,000+ students already improving their scores with Testiva. No credit card needed.',
      icon: Icons.emoji_events_outlined,
      wash: Color(0xFFDCFCE7),
      iconColor: Color(0xFF166534),
      accent: Color(0xFF147D6C),
    ),
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
          _currentPage = (_currentPage + 1) % _slides.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openAuth({required bool startOnLogin}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(startOnLogin: startOnLogin),
      ),
    );
  }

  void _continueAsGuest() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 720;
    final gap = compact ? 16.0 : 28.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, compact ? 12 : 16, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: Column(
                  children: [
                    const OnboardingHeader(),
                    SizedBox(height: gap),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: _buildPageContent(_currentPage, constraints.maxWidth),
                    ),
                    SizedBox(height: gap),
                    _buildBottomSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(int index, double maxWidth) {
    final slide = _slides[index];
    final heroHeight = (maxWidth - 8).clamp(180.0, 260.0);

    return Column(
      key: ValueKey<int>(index),
      children: [
        Container(
          height: heroHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: slide.wash,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Icon(slide.icon, size: 72, color: slide.iconColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: AppTypography.display(),
        ),
        const SizedBox(height: 12),
        Text(
          slide.subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body(color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    final slide = _slides[_currentPage];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) => _buildDot(index, slide.accent)),
        ),
        const SizedBox(height: 24),
        const OnboardingStats(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _openAuth(startOnLogin: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get Started', style: AppTypography.button()),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _continueAsGuest,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Continue as Guest (Limited Access)',
                maxLines: 1,
                style: AppTypography.button(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, Color accent) {
    final active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: active ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? accent : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
