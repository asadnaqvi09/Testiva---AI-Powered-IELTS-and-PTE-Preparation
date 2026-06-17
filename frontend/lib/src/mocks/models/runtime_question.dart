/// UI-facing question kinds aligned with Admin-Prototype / backend types.
enum QuestionKind {
  mcq,
  multiSelect,
  trueFalseNg,
  yesNoNg,
  matching,
  sentenceCompletion,
  shortAnswer,
  formFill,
  writing,
  unknown,
}

class RuntimeQuestion {
  final String id;
  final String sectionType;
  final String sectionName;
  final QuestionKind kind;
  final String typeLabel;
  final String text;
  final List<String> options;
  final String passageText;
  final String? audioUrl;
  final String? imageUrl;
  final int minWords;
  final int maxWords;
  final String? wordLimitInstruction;
  final List<Map<String, String>> matchingKeys;
  final String? cueCard;

  const RuntimeQuestion({
    required this.id,
    required this.sectionType,
    required this.sectionName,
    required this.kind,
    required this.typeLabel,
    required this.text,
    this.options = const [],
    this.passageText = '',
    this.audioUrl,
    this.imageUrl,
    this.minWords = 0,
    this.maxWords = 0,
    this.wordLimitInstruction,
    this.matchingKeys = const [],
    this.cueCard,
  });

  bool get isWriting => kind == QuestionKind.writing;
  bool get isObjective => !isWriting;
  bool get hasPassage => passageText.trim().isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

class TestRuntimeParser {
  static const _skipSections = {'speaking'};

  static List<RuntimeQuestion> parseRuntimePayload(Map<String, dynamic> data) {
    final sections = data['sections'] as List? ?? [];
    final List<RuntimeQuestion> out = [];

    for (final sec in sections) {
      final sectionType = (sec['section_type'] as String? ?? '').toLowerCase();
      if (_skipSections.contains(sectionType)) continue;

      final sectionName = sec['section_name'] as String? ?? sectionType;
      final instructions = sec['instructions'] as String? ?? '';
      final questions = sec['questions'] as List? ?? [];

      for (final q in questions) {
        final qt = (q['question_type'] as String? ?? '').toLowerCase();
        if (qt == 'placeholder') continue;

        final sub = (q['sub_question_type'] as String? ?? '').toLowerCase();
        final kind = _resolveKind(qt, sub);
        if (kind == QuestionKind.unknown && qt.isEmpty) continue;

        final passage = (q['passage_text'] as String? ?? '').trim();
        final content = q['content'] as Map<String, dynamic>? ?? {};
        final options = _parseOptions(q['options']);

        List<Map<String, String>> matchingKeys = [];
        if (kind == QuestionKind.matching) {
          final ca = q['correct_answer'];
          if (ca is List) {
            for (final item in ca) {
              if (item is Map) {
                matchingKeys.add({
                  'key': item['key']?.toString() ?? '',
                  'value': item['value']?.toString() ?? '',
                });
              }
            }
          }
          if (matchingKeys.isEmpty && options.isNotEmpty) {
            matchingKeys = options.map((o) => {'key': o, 'value': ''}).toList();
          }
        }

        out.add(RuntimeQuestion(
          id: q['id']?.toString() ?? '',
          sectionType: sectionType,
          sectionName: sectionName,
          kind: kind,
          typeLabel: labelForKind(kind, sub),
          text: q['question_text'] as String? ?? '',
          options: options,
          passageText: passage.isNotEmpty ? passage : instructions,
          audioUrl: q['audio_url'] as String?,
          imageUrl: q['image_url'] as String?,
          minWords: int.tryParse(q['min_words']?.toString() ?? '') ?? 0,
          maxWords: int.tryParse(q['max_words']?.toString() ?? '') ?? 0,
          wordLimitInstruction: q['word_limit_instruction'] as String?,
          matchingKeys: matchingKeys,
          cueCard: content['cue_card'] as String?,
        ));
      }
    }
    return out;
  }

  static QuestionKind _resolveKind(String qt, String sub) {
    if (qt == 'writing' || qt == 'essay' || sub.contains('chart') || sub.contains('opinion') || sub.contains('task_')) {
      return QuestionKind.writing;
    }
    if (qt == 'mcq' || sub == 'mcq') return QuestionKind.mcq;
    if (qt == 'multi_select' || sub == 'multi_select') return QuestionKind.multiSelect;
    if (qt == 'true_false' || sub == 'tf_not_given') return QuestionKind.trueFalseNg;
    if (qt == 'yes_no' || sub == 'yn_not_given') return QuestionKind.yesNoNg;
    if (qt == 'matching' || sub == 'matching') return QuestionKind.matching;
    if (qt == 'sentence_completion' || sub == 'sentence_completion') return QuestionKind.sentenceCompletion;
    if (qt == 'form_fill' || sub == 'form_fill') return QuestionKind.formFill;
    if (qt == 'short_answer' || sub == 'short_answer') return QuestionKind.shortAnswer;
    return QuestionKind.unknown;
  }

  static List<String> _parseOptions(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    return [];
  }

  static String labelForKind(QuestionKind kind, String sub) {
    switch (kind) {
      case QuestionKind.mcq:
        return 'MCQ';
      case QuestionKind.multiSelect:
        return 'Multi-select';
      case QuestionKind.trueFalseNg:
        return 'T/F/NG';
      case QuestionKind.yesNoNg:
        return 'Yes/No/NG';
      case QuestionKind.matching:
        return 'Matching';
      case QuestionKind.sentenceCompletion:
        return 'Sentence Completion';
      case QuestionKind.shortAnswer:
        return 'Short Answer';
      case QuestionKind.formFill:
        return 'Form Fill';
      case QuestionKind.writing:
        return sub.isNotEmpty ? sub.replaceAll('_', ' ') : 'Writing';
      default:
        return 'Question';
    }
  }

  /// Friendly chip labels for dashboard `sub_question_type_indicators`.
  static String chipLabel(String raw) {
    final key = raw.toLowerCase().replaceAll(' ', '_');
    const map = {
      'mcq': 'MCQ',
      'multi_select': 'Multi-select',
      'tf_not_given': 'T/F/NG',
      'true_false': 'T/F/NG',
      'yn_not_given': 'Yes/No/NG',
      'yes_no': 'Yes/No/NG',
      'matching': 'Matching',
      'sentence_completion': 'Sentence Completion',
      'short_answer': 'Short Answer',
      'form_fill': 'Form Fill',
      'chart_description': 'Chart Description',
      'opinion': 'Opinion Essay',
      'discussion': 'Discussion Essay',
      'problem_solution': 'Problem & Solution',
      'advantages_disadvantages': 'Adv/Disadv',
      'two_part_question': 'Two-Part',
      'request_information': 'Letter',
      'explain_situation': 'Letter',
      'provide_opinion': 'Letter',
      'part_1': 'Speaking P1',
      'part_2': 'Speaking P2',
      'part_3': 'Speaking P3',
    };
    return map[key] ?? raw;
  }
}
