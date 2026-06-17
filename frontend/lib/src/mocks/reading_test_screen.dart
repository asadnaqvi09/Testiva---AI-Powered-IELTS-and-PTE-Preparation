import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../widgets/app_theme.dart';
import 'test_results_screen.dart';


class ReadingQuestion {
  final String id;
  final String type;
  final String text;
  final List<String> options;
  final String passageTitle;
  final String passageText;
  final String? imageUrl;

  const ReadingQuestion({
    required this.id,
    required this.type,
    required this.text,
    this.options = const [],
    required this.passageTitle,
    required this.passageText,
    this.imageUrl,
  });
}

class ReadingTestScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final int totalDurationMinutes;

  const ReadingTestScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    this.totalDurationMinutes = 20,
  });

  @override
  State<ReadingTestScreen> createState() => _ReadingTestScreenState();
}

class _ReadingTestScreenState extends State<ReadingTestScreen> {
  int _currentIndex = 0;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  bool _isPassageExpanded = true;
  final Map<int, dynamic> _masterUserAnswers = {};
  List<ReadingQuestion> _questions = [];
  bool _isLoading = false;
  late DateTime _startedAt;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalDurationMinutes * 60;
    _startedAt = DateTime.now();
    _fetchTestDetails();
  }

  Future<void> _fetchTestDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.get('/content/test/${widget.testId}/runtime');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final sections = body['data']['sections'] as List;
          final List<ReadingQuestion> loaded = [];
          for (var sec in sections) {
            final passageTextFallback = sec['instructions'] as String? ?? '';
            final passageTitle = sec['section_name'] as String? ?? 'Section';
            final list = sec['questions'] as List? ?? [];
            for (var q in list) {
              final rawType = q['question_type'] as String? ?? 'Short Answer';
              String mappedType = 'Short Answer';
              if (rawType.toLowerCase().contains('mcq') || rawType.toLowerCase().contains('choice')) {
                mappedType = 'Multiple Choice';
              } else if (rawType.toLowerCase().contains('true') || rawType.toLowerCase().contains('false')) {
                mappedType = 'True / False / NG';
              } else if (rawType.toLowerCase().contains('yes') || rawType.toLowerCase().contains('no')) {
                mappedType = 'Yes / No / NG';
              }

              final qPassage = q['passage_text'] as String?;
              final finalPassage = (qPassage != null && qPassage.trim().isNotEmpty) ? qPassage : passageTextFallback;

              loaded.add(ReadingQuestion(
                id: q['id'] as String,
                type: mappedType,
                text: q['question_text'] as String? ?? '',
                options: List<String>.from(q['options'] ?? []),
                passageText: finalPassage,
                passageTitle: passageTitle,
                imageUrl: q['image_url'] as String?,
              ));
            }
          }
          setState(() {
            _questions = loaded;
          });
          _updateInputController();
          _startTimer();
        }
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _countdownTimer?.cancel();
        _finalizeTestSubmission();
      }
    });
  }

  void _updateInputController() {
    final currentAnswer = _masterUserAnswers[_currentIndex] ?? '';
    _inputController.text = currentAnswer;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  String _getFormattedTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _finalizeTestSubmission() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Quiz?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Do you want to finalize and submit your answers for review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Review Answers', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _submitTestAttempt();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066F5)),
            child: const Text('Yes, Submit', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> _submitTestAttempt() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Map<String, dynamic>> responsesList = [];
      final timeTaken = widget.totalDurationMinutes * 60 - _remainingSeconds;
      final timeSpentPerQ = _questions.isEmpty ? 0 : timeTaken ~/ _questions.length;

      for (int i = 0; i < _questions.length; i++) {
        responsesList.add({
          'question_id': _questions[i].id,
          'user_answer': _masterUserAnswers[i]?.toString() ?? '',
          'time_spent_seconds': timeSpentPerQ,
        });
      }

      final body = {
        'test_id': widget.testId,
        'client_started_at': _startedAt.toIso8601String(),
        'client_completed_at': DateTime.now().toIso8601String(),
        'responses': responsesList,
      };

      final response = await ApiService.post('/progress/submit-test', body);
      if (response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final attemptId = resData['data']['attemptId'] as String;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestResultsScreen(
                attemptId: attemptId,
                onRetake: () {
                  setState(() {
                    _currentIndex = 0;
                    _remainingSeconds = widget.totalDurationMinutes * 60;
                    _masterUserAnswers.clear();
                    _isPassageExpanded = true;
                    _startedAt = DateTime.now();
                  });
                  _updateInputController();
                  Navigator.pop(context);
                  _countdownTimer?.cancel();
                  _startTimer();
                },
                onAllTestsPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'switch_to_mocks');
                },
              ),
            ),
          );
        }
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(context),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.iconColor(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Test Taking', style: TextStyle(color: AppTheme.primaryText(context))),
          backgroundColor: AppTheme.appBarBg(context),
          elevation: 0,
        ),
        body: Center(child: Text('No questions loaded.', style: TextStyle(color: AppTheme.primaryText(context)))),
      );
    }

    var currentQuestion = _questions[_currentIndex];
    final isDark = AppTheme.isDark(context);
    final nextBtnColor = isDark ? Colors.blueAccent : const Color(0xFF0066F5);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.appBarBg(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.iconColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Time Left: ${_getFormattedTime()}',
          style: TextStyle(color: AppTheme.primaryText(context), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (currentQuestion.passageText.trim().isNotEmpty || currentQuestion.imageUrl != null)
            IconButton(
              icon: Icon(Icons.unfold_more, color: AppTheme.iconColor(context)),
              onPressed: () => setState(() => _isPassageExpanded = !_isPassageExpanded),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          if (_isPassageExpanded && (currentQuestion.passageText.trim().isNotEmpty || currentQuestion.imageUrl != null)) ...[
                            Expanded(
                              flex: 4,
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceBg(context),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderColor(context)),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentQuestion.passageTitle,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context)),
                                      ),
                                      const SizedBox(height: 12),
                                      if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              currentQuestion.imageUrl!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                      if (currentQuestion.passageText.trim().isNotEmpty)
                                        Text(
                                          currentQuestion.passageText,
                                          style: TextStyle(fontSize: 14, height: 1.6, color: AppTheme.primaryText(context).withValues(alpha: 0.8)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(height: 1, color: AppTheme.dividerColor(context)),
                          ],
                          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.tagBg(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentQuestion.type,
                          style: TextStyle(color: AppTheme.tagText(context), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_currentIndex + 1}. ${currentQuestion.text}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildInputWidget(context, currentQuestion),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentIndex > 0)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _currentIndex--);
                            _updateInputController();
                          },
                          icon: Icon(Icons.arrow_back, size: 16, color: AppTheme.primaryText(context)),
                          label: Text('Prev', style: TextStyle(color: AppTheme.primaryText(context))),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.borderColor(context)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (_currentIndex < _questions.length - 1)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _currentIndex++);
                            _updateInputController();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: nextBtnColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Next', style: TextStyle(color: Colors.white)),
                        )
                      else
                        ElevatedButton(
                          onPressed: _finalizeTestSubmission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Submit Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInputWidget(BuildContext context, ReadingQuestion question) {
    if (question.type == 'Multiple Choice') {
      return Column(
        children: question.options.map((option) {
          bool isSelected = _masterUserAnswers[_currentIndex] == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.tagBg(context) : AppTheme.cardBg(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppTheme.tagText(context) : AppTheme.borderColor(context)),
            ),
            child: ListTile(
              title: Text(option, style: TextStyle(fontSize: 14, color: AppTheme.primaryText(context))),
              leading: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppTheme.tagText(context) : AppTheme.secondaryText(context)),
              onTap: () => setState(() => _masterUserAnswers[_currentIndex] = option),
            ),
          );
        }).toList(),
      );
    } else if (question.type == 'True / False / NG' || question.type == 'Yes / No / NG') {
      List<String> options = question.type == 'True / False / NG' ? ['True', 'False', 'Not Given'] : ['Yes', 'No', 'Not Given'];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          bool isSelected = _masterUserAnswers[_currentIndex] == option;
          return ElevatedButton(
            onPressed: () => setState(() => _masterUserAnswers[_currentIndex] = option),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? AppTheme.tagText(context) : AppTheme.surfaceBg(context),
              foregroundColor: isSelected ? Colors.white : AppTheme.primaryText(context),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(option),
          );
        }).toList(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.inputFill(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor(context)),
        ),
        child: TextField(
          controller: _inputController,
          style: TextStyle(color: AppTheme.primaryText(context)),
          onChanged: (val) {
            _masterUserAnswers[_currentIndex] = val;
          },
          decoration: InputDecoration(
            hintText: 'Type your response here...',
            hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
            border: InputBorder.none,
          ),
        ),
      );
    }
  }
}