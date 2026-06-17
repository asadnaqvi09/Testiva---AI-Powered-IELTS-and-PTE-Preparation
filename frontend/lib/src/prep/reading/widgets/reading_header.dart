import 'package:flutter/material.dart';
import '../../../../widgets/app_theme.dart';

class ReadingHeader extends StatelessWidget {
  const ReadingHeader({super.key});

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
              Icon(Icons.arrow_back, size: 20, color: linkColor),
              const SizedBox(width: 5),
              Text(
                'Back to Prep',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.w600,
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
                color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book, color: isDark ? Colors.blueAccent : Colors.blue),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IELTS Reading',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                Text(
                  '12 lessons & tips',
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