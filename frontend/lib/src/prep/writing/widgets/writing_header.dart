import 'package:flutter/material.dart';
import '../../../../widgets/app_theme.dart';

class WritingHeader extends StatelessWidget {
  const WritingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final linkColor = isDark ? Colors.blueAccent : Colors.blue[700];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: linkColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Back to Prep',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IELTS Writing',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                Text(
                  '8 lessons & tips',
                  style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}