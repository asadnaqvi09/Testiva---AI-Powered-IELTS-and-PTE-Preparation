import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:frontend/widgets/app_header.dart';
import 'dynamic_test_screen.dart';
import 'models/runtime_question.dart';

class TestOverviewScreen extends StatelessWidget {
  final String testId;
  final String testTitle;
  final String examType;
  final String testCategory;
  final int questionCount;
  final int duration;
  final String difficulty;
  final double minBand;
  final List<String> questionTypes;

  const TestOverviewScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    this.examType = 'IELTS',
    this.testCategory = 'full_mock',
    required this.questionCount,
    required this.duration,
    required this.difficulty,
    required this.minBand,
    required this.questionTypes,
  });

  String get _subtitle {
    if (testCategory == 'singular_module') {
      return '$examType Module — $questionCount Questions';
    }
    return '$examType Full Mock — $questionCount Questions';
  }

  List<String> get _instructions {
    return [
      'Navigate freely between questions using Next and Prev.',
      'Listening sections include audio — use headphones for best results.',
      'Writing responses are evaluated by Testiva AI after submission.',
      'Speaking sections are configured in admin but skipped in the mobile app for now.',
      'Submit when finished — results appear after scoring completes.',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppHeader(
        showBackButton: true,
        titleWidget: Text(
          testTitle,
          style: TextStyle(color: AppTheme.primaryText(context), fontWeight: FontWeight.bold, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    testTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    style: TextStyle(fontSize: 14, color: AppTheme.secondaryText(context), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildInfoCard(context, Icons.timer_outlined, 'Duration', '$duration minutes', Colors.deepPurple),
                      _buildInfoCard(context, Icons.help_outline, 'Questions', '$questionCount Qs', Colors.red),
                      _buildInfoCard(context, Icons.bar_chart_outlined, 'Scoring', 'Band $minBand – 9.0', Colors.blue),
                      _buildInfoCard(context, Icons.track_changes, 'Difficulty', difficulty, Colors.pink),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (questionTypes.isNotEmpty) _buildQuestionTypesSection(context),
                  const SizedBox(height: 20),
                  _buildInstructionsSection(context),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Start Test',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicTestScreen(
                            testId: testId,
                            testTitle: testTitle,
                            totalDurationMinutes: duration,
                          ),
                        ),
                      );
                      if (result == 'switch_to_mocks' && context.mounted) {
                        Navigator.pop(context, 'switch_to_mocks');
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 13, color: AppTheme.primaryText(context), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypesSection(BuildContext context) {
    final chips = questionTypes.map((t) => TestRuntimeParser.chipLabel(t)).toSet().toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Types in this Test',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((type) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.tagBg(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type,
                style: TextStyle(color: AppTheme.tagText(context), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? Colors.blue.withValues(alpha: 0.12) : const Color(0xFFEEF7FF);
    final borderColor = isDark ? Colors.blue.withValues(alpha: 0.25) : const Color(0xFFD0E8FF);
    final linkColor = isDark ? Colors.blueAccent : Colors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: linkColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: linkColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._instructions.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle, color: linkColor, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(fontSize: 13, color: AppTheme.primaryText(context).withValues(alpha: 0.8), height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
