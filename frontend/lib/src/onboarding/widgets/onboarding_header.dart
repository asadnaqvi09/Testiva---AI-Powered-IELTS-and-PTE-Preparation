import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';
import 'package:frontend/widgets/brand_mark.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: BrandMark(
            markSize: 40,
            fontSize: 18,
            showSubtitle: true,
            subtitle: 'AI-Powered Test Prep',
            expandText: true,
          ),
        ),
        SizedBox(width: 8),
        _RatingChip(),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '4.9 Rating',
            style: AppTypography.caption(
              color: AppColors.primary,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
