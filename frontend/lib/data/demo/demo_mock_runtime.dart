/// Bundled offline runtimes for seed mock IDs (testiva.sql).
/// Lets students open + take mocks without a prior online cache.
class DemoMockRuntime {
  static bool has(String testId) => _payloads.containsKey(testId);

  static Map<String, dynamic>? payloadFor(String testId) {
    final raw = _payloads[testId];
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  static const _passage =
      'Cities currently account for approximately 70 percent of global energy '
      'consumption and over 60 percent of greenhouse gas emissions, yet they '
      'cover less than three percent of the Earth\'s land surface. Singapore '
      'has emerged as a benchmark for sustainable city design. Copenhagen has '
      'pursued a transport-focused approach, placing cycling at the heart of '
      'urban planning.';

  // clean and optimized code — IDs match Backend/src/database/testiva.sql
  static final Map<String, Map<String, dynamic>> _payloads = {
    'd2319e2d-12d4-440a-8af0-75fa93f537eb': {
      'id': 'd2319e2d-12d4-440a-8af0-75fa93f537eb',
      'title': 'IELTS Reading',
      'exam_type': 'IELTS',
      'test_category': 'singular_module',
      'sections': [
        {
          'section_type': 'reading',
          'section_name': 'Reading',
          'instructions': _passage,
          'questions': [
            {
              'id': '4e67985b-05ec-403f-b7ff-81ccdb1afe27',
              'question_type': 'mcq',
              'sub_question_type': 'mcq',
              'question_text':
                  'What percentage of global energy consumption is attributed to cities?',
              'passage_text': _passage,
              'options': ['50%', '60%', '70%', '80%'],
            },
            {
              'id': 'acbd6c96-b1e6-47ad-8b64-1ba3b2a4e60c',
              'question_type': 'true_false',
              'sub_question_type': 'tf_not_given',
              'question_text':
                  'Singapore\'s "City in a Garden" initiative was launched before 2010.',
              'passage_text': _passage,
              'options': ['True', 'False', 'Not Given'],
            },
            {
              'id': 'a4b3c856-db1f-45f3-9900-a72676fd5e18',
              'question_type': 'true_false',
              'sub_question_type': 'tf_not_given',
              'question_text':
                  'Copenhagen\'s cycling infrastructure was funded primarily by private companies.',
              'passage_text': _passage,
              'options': ['True', 'False', 'Not Given'],
            },
            {
              'id': 'a69746f3-7e50-4b02-a751-da555b6f6d26',
              'question_type': 'yes_no',
              'sub_question_type': 'yn_not_given',
              'question_text':
                  'The writer implies that new green building construction is always the most effective approach to reducing carbon emissions.',
              'passage_text': _passage,
              'options': ['Yes', 'No', 'Not Given'],
            },
            {
              'id': '95749493-e4e7-4e95-a617-78862da1afc5',
              'question_type': 'short_answer',
              'sub_question_type': 'short_answer',
              'question_text':
                  'According to the passage, what percentage of Singapore\'s buildings had Green Mark certification by 2023?',
              'passage_text': _passage,
              'options': <String>[],
            },
          ],
        },
      ],
    },
    '047684a1-5841-4c06-90cc-44dcde456ae5': {
      'id': '047684a1-5841-4c06-90cc-44dcde456ae5',
      'title': 'IELTS Writing',
      'exam_type': 'IELTS',
      'test_category': 'singular_module',
      'sections': [
        {
          'section_type': 'writing',
          'section_name': 'Writing',
          'instructions': 'Write at least 150 words.',
          'questions': [
            {
              'id': '9dff95d2-6635-4c8c-9205-dec716d25da0',
              'question_type': 'writing',
              'sub_question_type': 'chart_description',
              'question_text':
                  'The graph below shows the number of international students enrolled in universities in three different countries between 2010 and 2020.\n\nSummarize the information by selecting and reporting the main features, and make comparisons where relevant.',
              'min_words': 150,
              'options': <String>[],
            },
            {
              'id': 'eda32d0e-472b-472e-a9c3-a374bf65053f',
              'question_type': 'writing',
              'sub_question_type': 'provide_opinion',
              'question_text':
                  'Your city plans to introduce electric buses for public transport.\n\nWrite a letter to the local council. In your letter:\ngive your opinion about the plan\nexplain how it may affect citizens\nsuggest improvements for the transport system',
              'min_words': 150,
              'options': <String>[],
            },
          ],
        },
      ],
    },
  };
}
