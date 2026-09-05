import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';

/// Blue rounded open-book mark + Testiva wordmark. Never use Figma's "Test Prep Hub".
class BrandMark extends StatelessWidget {
  final double markSize;
  final double fontSize;
  final bool showSubtitle;
  final String subtitle;
  final bool expandText;

  const BrandMark({
    super.key,
    this.markSize = 40,
    this.fontSize = 18,
    this.showSubtitle = false,
    this.subtitle = 'AI-Powered Test Prep',
    this.expandText = false,
  });

  @override
  Widget build(BuildContext context) {
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Testiva',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption(color: const Color(0xFF94A3B8)),
          ),
        ],
      ],
    );

    return Row(
      mainAxisSize: expandText ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          width: markSize,
          height: markSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.menu_book_outlined,
            color: Colors.white,
            size: markSize * 0.52,
          ),
        ),
        const SizedBox(width: 10),
        if (expandText) Flexible(child: texts) else texts,
      ],
    );
  }
}
