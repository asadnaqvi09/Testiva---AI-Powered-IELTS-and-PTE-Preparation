import 'package:flutter/material.dart';
import '../../../widgets/app_theme.dart';

class EmailVerifiedScreen extends StatelessWidget {
  final String userName;

  const EmailVerifiedScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final scaffoldBg = AppTheme.scaffoldBg(context);
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);

    // Green success colors matching screenshots, with dark mode fallbacks
    final cardBg = isDark ? const Color(0xFF166534).withValues(alpha: 0.2) : const Color(0xFFF0FDF4);
    final borderColor = isDark ? const Color(0xFF15803D).withValues(alpha: 0.4) : const Color(0xFFDCFCE7);
    final iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    final textColor = isDark ? const Color(0xFFD1FAE5) : const Color(0xFF15803D);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Checked Green Badge with Sparkle Accent
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF22C55E),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF22C55E),
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Email Verified!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 26),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: secondaryText,
                  ),
                  children: [
                    const TextSpan(text: 'Your account has been successfully created.\nWelcome to '),
                    const TextSpan(
                      text: 'TestPrep Hub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    TextSpan(text: ', $userName!'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Milestone Cards List
              _buildMilestoneCard(
                icon: Icons.check_circle_outline,
                label: 'Email address verified',
                bg: cardBg,
                border: borderColor,
                iconColor: iconColor,
                textColor: textColor,
              ),
              const SizedBox(height: 12),
              _buildMilestoneCard(
                icon: Icons.check_circle_outline,
                label: 'Account created successfully',
                bg: cardBg,
                border: borderColor,
                iconColor: iconColor,
                textColor: textColor,
              ),
              const SizedBox(height: 12),
              _buildMilestoneCard(
                icon: Icons.check_circle_outline,
                label: 'Ready to start learning',
                bg: cardBg,
                border: borderColor,
                iconColor: iconColor,
                textColor: textColor,
              ),

              const Spacer(),

              // Choose Preference Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/select-preference',
                      arguments: userName,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Choose Your Test Preference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneCard({
    required IconData icon,
    required String label,
    required Color bg,
    required Color border,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
