import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../data/models/mock_test_model.dart';
import '../models/runtime_question.dart';

class MockTestCard extends StatelessWidget {
  final MockTest mock;
  final VoidCallback onTap;

  const MockTestCard({
    super.key,
    required this.mock,
    required this.onTap,
  });

  Color _headerColor() {
    final cat = mock.testCategory.toLowerCase();
    final title = mock.title.toLowerCase();
    if (title.contains('listening') || cat.contains('listening')) {
      return const Color(0xFF1D4ED8);
    }
    if (title.contains('writing') || cat.contains('writing')) {
      return const Color(0xFF7C3AED);
    }
    if (title.contains('reading') || cat.contains('reading')) {
      return const Color(0xFF2563EB);
    }
    if (mock.examType == 'PTE') return const Color(0xFF8B5CF6);
    return const Color(0xFF2563EB);
  }

  IconData _headerIcon() {
    final title = mock.title.toLowerCase();
    if (title.contains('listening')) return Icons.headphones_rounded;
    if (title.contains('writing')) return Icons.edit_note_rounded;
    if (title.contains('reading')) return Icons.menu_book_rounded;
    return Icons.assignment_outlined;
  }

  String _subtitle() {
    if (mock.testCategory == 'singular_module') {
      return '${mock.examType} Module — ${mock.totalQuestions} Questions';
    }
    return '${mock.examType} Full Mock — ${mock.totalQuestions} Questions';
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _headerColor();
    final chips = mock.subQuestionTypeIndicators
        .map((e) => TestRuntimeParser.chipLabel(e))
        .toSet()
        .take(6)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: headerColor,
            child: Row(
              children: [
                Icon(_headerIcon(), color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mock.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mock.difficultyLevel,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _stat(context, Icons.timer_outlined, '${mock.totalDuration} min'),
                    const SizedBox(width: 16),
                    _stat(context, Icons.help_outline, '${mock.totalQuestions} questions'),
                    if (mock.lastAttemptScore != null) ...[
                      const Spacer(),
                      _stat(context, Icons.signal_cellular_alt, 'Band ${mock.lastAttemptScore}', green: true),
                    ],
                  ],
                ),
                if (mock.displayId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${mock.displayId}',
                    style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context)),
                  ),
                ],
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: chips
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.tagBg(context),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.tagText(context),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    label: Text(
                      mock.cta == 'retake' ? 'Retake Test' : 'Start Test',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, String text, {bool green = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: green ? Colors.green : AppTheme.secondaryText(context)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: green ? Colors.green.shade400 : AppTheme.secondaryText(context),
          ),
        ),
      ],
    );
  }
}
