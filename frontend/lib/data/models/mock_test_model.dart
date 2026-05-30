class MockTest {
  final String id;
  final int displayId;
  final String title;
  final String examType;
  final String testCategory;
  final String difficultyLevel;
  final int totalDuration;
  final double minRequiredBand;
  final int totalQuestions;
  final List<String> subQuestionTypeIndicators;
  final String? lastAttemptId;
  final double? lastAttemptScore;
  final String? lastAttemptStatus;
  final String cta;

  MockTest({
    required this.id,
    required this.displayId,
    required this.title,
    required this.examType,
    required this.testCategory,
    required this.difficultyLevel,
    required this.totalDuration,
    required this.minRequiredBand,
    required this.totalQuestions,
    required this.subQuestionTypeIndicators,
    this.lastAttemptId,
    this.lastAttemptScore,
    this.lastAttemptStatus,
    required this.cta,
  });

  factory MockTest.fromJson(Map<String, dynamic> json) {
    final lastAttempt = json['last_attempt'] as Map<String, dynamic>?;

    return MockTest(
      id: json['id']?.toString() ?? '',
      displayId: int.tryParse(json['display_id']?.toString() ?? '') ?? 1,
      title: json['title']?.toString() ?? 'IELTS Mock Test',
      examType: json['exam_type']?.toString() ?? 'IELTS',
      testCategory: json['test_category']?.toString() ?? 'Reading',
      difficultyLevel: json['difficulty']?.toString() ??
          json['difficulty_level']?.toString() ?? 'Medium',
      totalDuration: int.tryParse(json['duration']?.toString() ?? '') ??
          int.tryParse(json['total_duration']?.toString() ?? '') ?? 60,
      minRequiredBand: double.tryParse(json['min_band']?.toString() ?? '') ??
          double.tryParse(json['min_required_band']?.toString() ?? '') ?? 5.5,
      totalQuestions: int.tryParse(json['questions']?.toString() ?? '') ??
          int.tryParse(json['total_questions']?.toString() ?? '') ?? 40,
      subQuestionTypeIndicators: (json['sub_question_type_indicators'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? const ['Multiple Choice', 'Short Answer'],
      lastAttemptId: lastAttempt?['attempt_id']?.toString(),
      lastAttemptScore: lastAttempt?['overall_band_score'] != null
          ? double.tryParse(lastAttempt!['overall_band_score'].toString())
          : null,
      lastAttemptStatus: lastAttempt?['status']?.toString(),
      cta: json['cta']?.toString() ?? 'open',
    );
  }
}