import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../data/models/mock_test_model.dart';
import '../models/runtime_question.dart';

class MockTestCard extends StatelessWidget {
  final MockTest mock;
  final VoidCallback onTap;
  final bool isLocked;

  const MockTestCard({
    super.key,
    required this.mock,
    required this.onTap,
    this.isLocked = false,
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
    if (title.contains('speaking') || cat.contains('speaking')) {
      return const Color(0xFFDB2777);
    }
    if (title.contains('reading') || cat.contains('reading')) {
      return const Color(0xFF2563EB);
    }
    if (mock.examType == 'PTE') return const Color(0xFF059669);
    return const Color(0xFF2563EB);
  }

  IconData _headerIcon() {
    final title = mock.title.toLowerCase();
    if (title.contains('listening')) return Icons.headphones_rounded;
    if (title.contains('writing')) return Icons.edit_note_rounded;
    if (title.contains('speaking')) return Icons.mic_rounded;
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerColor, headerColor.withValues(alpha: 0.75)],
              ),
            ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
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
                      if (isLocked)
                        const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                    ],
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
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _stat(context, Icons.timer_outlined, '${mock.totalDuration} min'),
                    _stat(context, Icons.help_outline, '${mock.totalQuestions} questions'),
                    if (mock.lastAttemptScore != null)
                      _stat(context, Icons.signal_cellular_alt, 'Band ${mock.lastAttemptScore}', green: true),
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
                if (isLocked) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: Color(0xFFC2410C)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upgrade to Basic (Rs399) to unlock mock tests',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF9A3412),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                      label: const Text(
                        'Upgrade to Unlock',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else
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
