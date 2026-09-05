/// Local FYP catalog used when the dashboard API is unreachable or returns
/// an auth/DB error. IDs for IELTS items match `Backend/src/database/testiva.sql`.
class DemoMockCatalog {
  static const List<Map<String, dynamic>> items = [
    {
      'id': 'd2319e2d-12d4-440a-8af0-75fa93f537eb',
      'display_id': 'mck001',
      'title': 'IELTS Reading',
      'exam_type': 'IELTS',
      'test_category': 'singular_module',
      'difficulty_level': 'medium',
      'total_duration': 60,
      'min_required_band': 6.0,
      'total_questions': 8,
      'sub_question_type_indicators': ['mcq', 'true_false', 'yes_no', 'short_answer'],
      'last_attempt': null,
      'cta': 'start',
    },
    {
      'id': '047684a1-5841-4c06-90cc-44dcde456ae5',
      'display_id': 'mck002',
      'title': 'IELTS Writing',
      'exam_type': 'IELTS',
      'test_category': 'singular_module',
      'difficulty_level': 'medium',
      'total_duration': 60,
      'min_required_band': 6.0,
      'total_questions': 12,
      'sub_question_type_indicators': [
        'chart_description',
        'opinion',
        'request_information',
      ],
      'last_attempt': null,
      'cta': 'start',
    },
    {
      'id': 'b7c1e9a0-4d2f-4a11-9c8e-21f0a6d4e801',
      'display_id': 'mck003',
      'title': 'PTE Academic Practice',
      'exam_type': 'PTE',
      'test_category': 'full_mock',
      'difficulty_level': 'medium',
      'total_duration': 90,
      'min_required_band': 65,
      'total_questions': 20,
      'sub_question_type_indicators': ['mcq', 'short_answer', 'sentence_completion'],
      'last_attempt': null,
      'cta': 'start',
    },
  ];

  static List<Map<String, dynamic>> forExamType(String examType) {
    final key = examType.toUpperCase();
    if (key == 'ALL') return List<Map<String, dynamic>>.from(items);
    return items
        .where((m) => (m['exam_type']?.toString().toUpperCase() ?? '') == key)
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
}
