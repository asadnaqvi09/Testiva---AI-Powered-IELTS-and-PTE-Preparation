import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

class DailyTipsList extends StatelessWidget {
  const DailyTipsList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(context),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: TextStyle(color: isDark ? Colors.blueAccent : const Color(0xFF007BFF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _tipCard(
            context,
            'Reading Tip',
            'Practice skimming passages in under 2 minutes to improve reading speed and comprehension.',
            Icons.menu_book,
            const Color(0xFFE3F2FD),
            const Color(0xFF007BFF)
        ),
        const SizedBox(height: 15),
        _tipCard(
            context,
            'Listening Strategy',
            'Listen to BBC World Service daily to improve accent recognition for IELTS Listening.',
            Icons.headphones,
            const Color(0xFFFFF8E1),
            const Color(0xFFFFA000)
        ),
        const SizedBox(height: 15),
        _tipCard(
            context,
            'Writing Boost',
            "Use linking phrases like 'furthermore', 'however' and 'in contrast' to improve cohesion score.",
            Icons.edit_note,
            const Color(0xFFE8F5E9),
            const Color(0xFF43A047)
        ),
        const SizedBox(height: 15),
        _tipCard(
            context,
            'Speaking Practice',
            'Record yourself speaking for 2 minutes on random topics. Review for fluency and vocabulary.',
            Icons.interpreter_mode,
            const Color(0xFFF3E5F5),
            const Color(0xFF8E24AA)
        ),
      ],
    );
  }

  Widget _tipCard(BuildContext context, String title, String desc, IconData icon, Color bg, Color iconCol) {
    final isDark = AppTheme.isDark(context);
    final cardBgColor = AppTheme.cardBg(context);
    final iconBgColor = isDark ? iconCol.withValues(alpha: 0.15) : bg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconCol, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}