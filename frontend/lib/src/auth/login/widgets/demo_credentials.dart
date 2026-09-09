import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class DemoCredentials extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(String email, String password) onFill;

  const DemoCredentials({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.onFill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  expanded ? 'Hide Demo Credentials' : 'Show Demo Credentials',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Demo Credentials (tap to fill)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DemoRow(
                  icon: Icons.badge_outlined,
                  iconColor: AppColors.primary,
                  label: 'Free User',
                  value: 'freeuser@example.com / password123',
                  onTap: () => onFill('freeuser@example.com', 'password123'),
                ),
                const SizedBox(height: 8),
                _DemoRow(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Premium User',
                  value: 'premiumuser@example.com / premium123',
                  onTap: () => onFill('premiumuser@example.com', 'premium123'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DemoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DemoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
