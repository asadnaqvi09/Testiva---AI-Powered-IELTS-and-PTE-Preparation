
enum MocksQuestionType { mcq, trueFalseNG, yesNoNG, matchingFeatures, shortAnswer, sentenceCompletion, matchingEndings }

class MocksReadingQuestion {
  final String id;
  final MocksQuestionType type;
  final String typeLabel;
  final String passageTitle;
  final String passageText;
  final String questionText;
  final String instruction;
  final List<String> options;
  final List<String>? matchingItems;

  MocksReadingQuestion({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.passageTitle,
    required this.passageText,
    required this.questionText,
    required this.instruction,
    this.options = const [],
    this.matchingItems,
  });
}


final List<MocksReadingQuestion> globalReadingQuestionsList = [
  MocksReadingQuestion(
    id: 'q1',
    type: MocksQuestionType.mcq,
    typeLabel: 'Multiple Choice',
    passageTitle: 'PASSAGE 1 — URBAN SUSTAINABILITY',
    passageText: "Cities currently account for approximately 70 percent of global energy consumption and over 60 percent of greenhouse gas emissions, yet they cover less than three percent of the Earth's land surface. As climate challenges intensify, urban planners face growing pressure to reimagine how cities function.\n\nSingapore has emerged as a benchmark for sustainable city design. The government launched its 'City in a Garden' vision in 2009, embedding green spaces throughout the urban landscape.",
    questionText: 'What percentage of global energy consumption is attributed to cities?',
    instruction: 'Choose ONE correct answer, A–D.',
    options: ['50%', '60%', '70%', '80%'],
  ),
  MocksReadingQuestion(
    id: 'q2',
    type: MocksQuestionType.trueFalseNG,
    typeLabel: 'True/False/NG',
    passageTitle: 'PASSAGE 1 — URBAN SUSTAINABILITY',
    passageText: "Singapore has emerged as a benchmark for sustainable city design. The government launched its 'City in a Garden' vision in 2009, embedding green spaces throughout the urban landscape. By 2023, over 43 percent of Singapore's buildings had received BCA Green Mark certification.",
    questionText: "Singapore's \"City in a Garden\" initiative was launched before 2010.",
    instruction: 'Do the following statements agree with the information in the passage? Write TRUE, FALSE or NOT GIVEN.',
    options: ['TRUE\nThe statement agrees with information in the passage', 'FALSE\nThe statement contradicts information in the passage', 'NOT GIVEN\nThe information is not found in the passage'],
  ),
  MocksReadingQuestion(
    id: 'q3',
    type: MocksQuestionType.yesNoNG,
    typeLabel: 'Yes/No/NG',
    passageTitle: 'PASSAGE 1 — URBAN SUSTAINABILITY',
    passageText: "Critics, however, question whether such projects represent genuine progress. Professor James Whitfield of Oxford University argues that 'the embodied carbon in constructing a new green building can take decades to offset through operational savings.' His research team advocates retrofitting existing buildings as a more carbon-effective strategy than new construction.",
    questionText: "The writer implies that new green building construction is always the most effective approach to reducing carbon emissions.",
    instruction: 'Do the following statements agree with the views/claims of the writer? Write YES, NO or NOT GIVEN.',
    options: ['YES', 'NO', 'NOT GIVEN'],
  ),
  MocksReadingQuestion(
    id: 'q4',
    type: MocksQuestionType.matchingFeatures,
    typeLabel: 'Matching Features',
    passageTitle: 'PASSAGE 1 — URBAN SUSTAINABILITY',
    passageText: "Singapore has embedded mandatory green building certification standards. Copenhagen uses cycling as its primary strategy. Oxford University team advocates retrofitting rather than new construction.",
    questionText: 'Match each city or institution (1–3) with the sustainability feature most closely associated with it in the passage.',
    instruction: 'Match each item to the correct option using the dropdowns below.',
    matchingItems: ['Singapore', 'Copenhagen', 'Oxford University team'],
    options: [
      'A. Advocates retrofitting rather than new construction',
      'B. Uses cycling as its primary climate strategy',
      'C. Has mandatory green building certification standards'
    ],
  ),
  MocksReadingQuestion(
    id: 'q5',
    type: MocksQuestionType.shortAnswer,
    typeLabel: 'Short Answer',
    passageTitle: 'PASSAGE 1 — URBAN SUSTAINABILITY',
    passageText: "Critics, however, question whether such projects represent genuine progress. Professor James Whitfield of Oxford University argues that 'the embodied carbon in constructing a new green building can take decades to offset through operational savings.' His research team advocates retrofitting existing buildings as a more carbon-effective strategy than new construction.",
    questionText: 'According to Professor Whitfield, what is a more carbon-effective strategy than constructing new green buildings?',
    instruction: 'Word limit: NO MORE THAN THREE WORDS',
  ),
];