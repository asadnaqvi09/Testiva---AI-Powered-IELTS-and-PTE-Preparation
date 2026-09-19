import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

class _TipItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color lightBg;
  final Color accent;

  const _TipItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.lightBg,
    required this.accent,
  });
}

class DailyTipsList extends StatelessWidget {
  const DailyTipsList({super.key});

  static const _tips = <_TipItem>[
    _TipItem(
      title: 'Reading Tip',
      desc:
          'Practice skimming passages in under 2 minutes to improve reading speed and comprehension.',
      icon: Icons.auto_stories,
      lightBg: Color(0xFFE3F2FD),
      accent: Color(0xFF1565C0),
    ),
    _TipItem(
      title: 'Listening Strategy',
      desc:
          'Listen to BBC World Service daily to improve accent recognition for IELTS Listening.',
      icon: Icons.headphones,
      lightBg: Color(0xFFFFF0E6),
      accent: Color(0xFFA67C52),
    ),
    _TipItem(
      title: 'Writing Boost',
      desc:
          "Use linking phrases like 'furthermore', 'however' and 'in contrast' to improve cohesion score.",
      icon: Icons.draw,
      lightBg: Color(0xFFE8F5E9),
      accent: Color(0xFF43A047),
    ),
    _TipItem(
      title: 'Speaking Practice',
      desc:
          'Record yourself speaking for 2 minutes on random topics. Review for fluency and vocabulary.',
      icon: Icons.record_voice_over,
      lightBg: Color(0xFFF3E5F5),
      accent: Color(0xFF7B1FA2),
    ),
    _TipItem(
      title: 'Mock Discipline',
      desc:
          'Take at least one timed mock section weekly. Review wrong answers the same day.',
      icon: Icons.timer_outlined,
      lightBg: Color(0xFFFFF8E1),
      accent: Color(0xFFF59E0B),
    ),
    _TipItem(
      title: 'Vocabulary Bank',
      desc:
          'Save 5 new academic words daily and reuse them in your next writing task.',
      icon: Icons.menu_book_outlined,
      lightBg: Color(0xFFE0F2FE),
      accent: Color(0xFF0284C7),
    ),
  ];

  void _openAllTips(BuildContext context) {
    // clean and optimized code — full tip sheet (was a dead "See all")
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.dialogBg(ctx),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All daily tips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(ctx),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quick strategies for Reading, Listening, Writing & Speaking.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondaryText(ctx),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < _tips.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _tipCard(ctx, _tips[i]),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final preview = _tips.take(4).toList();

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
              onPressed: () => _openAllTips(context),
              style: TextButton.styleFrom(
                foregroundColor:
                    isDark ? Colors.white70 : const Color(0xFF007BFF),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) const SizedBox(height: 15),
          _tipCard(context, preview[i]),
        ],
      ],
    );
  }

  Widget _tipCard(BuildContext context, _TipItem tip) {
    final isDark = AppTheme.isDark(context);
    final cardBgColor = AppTheme.cardBg(context);
    final iconBgColor =
        isDark ? tip.accent.withValues(alpha: 0.15) : tip.lightBg;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip.icon, color: tip.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.desc,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppTheme.secondaryText(context),
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
