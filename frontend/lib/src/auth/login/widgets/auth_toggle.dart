import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';

class AuthToggle extends StatelessWidget {
  final bool isLogin;
  final Function(bool) onChanged;

  const AuthToggle({super.key, required this.isLogin, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(label: 'Login', selected: isLogin, onTap: () => onChanged(true))),
          Expanded(child: _tab(label: 'Sign Up', selected: !isLogin, onTap: () => onChanged(false))),
        ],
      ),
    );
  }

  Widget _tab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.label(
              color: selected ? AppColors.primary : const Color(0xFF94A3B8),
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
