import 'package:flutter/material.dart';
import 'app_theme.dart';

class GlobalStatsCard extends StatelessWidget {
  final String value;
  final String line1;
  final String line2;
  final IconData? icon;
  final Color? iconColor;

  const GlobalStatsCard({
    super.key,
    required this.value,
    required this.line1,
    required this.line2,
    this.icon,
    this.iconColor,
    bool isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = iconColor ?? Colors.orange;
    final labelStyle = TextStyle(
      fontFamily: 'Inter',
      color: AppTheme.secondaryText(context),
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tint, size: 16),
            ),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText(context),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  line1,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  line2,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
