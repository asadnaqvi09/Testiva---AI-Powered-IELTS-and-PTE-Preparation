import 'package:flutter/material.dart';
import 'app_theme.dart';

class GlobalStatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const GlobalStatsCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    // Keep isDarkMode param for backward compatibility but ignore it (use AppTheme)
    bool isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          if (icon != null) Icon(icon, color: iconColor ?? Colors.orange, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText(context),
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}