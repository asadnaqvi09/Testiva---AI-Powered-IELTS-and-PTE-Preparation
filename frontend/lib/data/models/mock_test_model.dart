class MockTest {
  final String id;
  final String displayId;
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

  bool get hasAttempt => lastAttemptId != null;

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) {
      return value
          .replaceAll(RegExp(r'[{}]'), '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  factory MockTest.fromJson(Map<String, dynamic> json) {
    final lastAttempt = _asMap(json['last_attempt']);
    final examType = (json['exam_type']?.toString() ?? 'IELTS').toUpperCase();

    return MockTest(
      id: json['id']?.toString() ?? '',
      displayId: json['display_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'IELTS Mock Test',
      examType: examType == 'PTE' ? 'PTE' : 'IELTS',
      testCategory: json['test_category']?.toString() ?? 'full_mock',
      difficultyLevel: json['difficulty']?.toString() ??
          json['difficulty_level']?.toString() ?? 'Medium',
      totalDuration: int.tryParse(json['duration']?.toString() ?? '') ??
          int.tryParse(json['total_duration']?.toString() ?? '') ?? 60,
      minRequiredBand: double.tryParse(json['min_band']?.toString() ?? '') ??
          double.tryParse(json['min_required_band']?.toString() ?? '') ?? 5.5,
      totalQuestions: int.tryParse(json['questions']?.toString() ?? '') ??
          int.tryParse(json['total_questions']?.toString() ?? '') ?? 0,
      subQuestionTypeIndicators: _asStringList(
        json['sub_question_type_indicators'] ?? json['sub_question_types'],
      ),
      lastAttemptId: lastAttempt?['attempt_id']?.toString(),
      lastAttemptScore: lastAttempt?['overall_band_score'] != null
          ? double.tryParse(lastAttempt!['overall_band_score'].toString())
          : null,
      lastAttemptStatus: lastAttempt?['status']?.toString(),
      cta: json['cta']?.toString() ?? 'start',
    );
  }
}
