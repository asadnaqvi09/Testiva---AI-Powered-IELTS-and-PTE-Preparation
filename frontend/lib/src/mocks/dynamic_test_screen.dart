import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../widgets/app_theme.dart';
import 'models/runtime_question.dart';
import 'test_results_screen.dart';
import 'widgets/matching_engine.dart';
import 'widgets/selection_engine.dart';

class DynamicTestScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final int totalDurationMinutes;

  const DynamicTestScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    this.totalDurationMinutes = 60,
  });

  @override
  State<DynamicTestScreen> createState() => _DynamicTestScreenState();
}

class _DynamicTestScreenState extends State<DynamicTestScreen> {
  int _currentIndex = 0;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  bool _isPassageExpanded = true;
  final Map<int, dynamic> _answers = {};
  List<RuntimeQuestion> _questions = [];
  bool _isLoading = false;
  late DateTime _startedAt;
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingAudioUrl;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalDurationMinutes * 60;
    _startedAt = DateTime.now();
    _fetchTestDetails();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isAudioPlaying = false);
    });
  }

  Future<void> _fetchTestDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/content/test/${widget.testId}/runtime');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final loaded = TestRuntimeParser.parseRuntimePayload(body['data'] as Map<String, dynamic>);
          setState(() => _questions = loaded);
          _syncTextController();
          if (loaded.isNotEmpty) _startTimer();
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _confirmSubmit();
      }
    });
  }

  void _syncTextController() {
    final ans = _answers[_currentIndex];
    _textController.text = ans is String ? ans : '';
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
  }

  RuntimeQuestion? get _current => _questions.isEmpty ? null : _questions[_currentIndex];

  String? get _currentAudioUrl {
    final q = _current;
    if (q == null || !q.hasAudio) return null;
    return q.audioUrl;
  }

  Future<void> _toggleAudio() async {
    final url = _currentAudioUrl;
    if (url == null) return;
    try {
      if (_isAudioPlaying && _playingAudioUrl == url) {
        await _audioPlayer.pause();
        setState(() => _isAudioPlaying = false);
        return;
      }
      if (_playingAudioUrl != url) {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
        _playingAudioUrl = url;
      } else {
        await _audioPlayer.resume();
      }
      setState(() => _isAudioPlaying = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio. Check your connection.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formattedTime() {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _wordCount(String text) => text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Test?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Submit your answers for scoring and AI evaluation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Review')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066F5)),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  dynamic _serializeAnswer(RuntimeQuestion q, dynamic raw) {
    if (q.kind == QuestionKind.writing) {
      final text = raw is String ? raw : '';
      return text.trim().isEmpty ? '' : {'text_essay': text};
    }
    if (q.kind == QuestionKind.multiSelect && raw is List) {
      return raw;
    }
    if (q.kind == QuestionKind.matching && raw is Map) {
      return (raw as Map<String, String>).entries
          .map((e) => {'key': e.key, 'value': e.value})
          .toList();
    }
    return raw?.toString() ?? '';
  }

  Future<void> _submitTest() async {
    setState(() => _isLoading = true);
    try {
      final timeTaken = widget.totalDurationMinutes * 60 - _remainingSeconds;
      final perQ = _questions.isEmpty ? 0 : timeTaken ~/ _questions.length;
      final responses = <Map<String, dynamic>>[];

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final raw = _answers[i];
        final serialized = _serializeAnswer(q, raw);
        int wc = 0;
        if (q.isWriting && raw is String) wc = _wordCount(raw);

        responses.add({
          'question_id': q.id,
          'user_answer': serialized,
          'time_spent_seconds': perQ,
          if (wc > 0) 'word_count': wc,
        });
      }

      final body = {
        'test_id': widget.testId,
        'client_started_at': _startedAt.toIso8601String(),
        'client_completed_at': DateTime.now().toIso8601String(),
        'responses': responses,
      };

      final response = await ApiService.post('/progress/submit-test', body);
      if (response.statusCode == 201 || response.statusCode == 202) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final attemptId = resData['data']['attemptId'] as String;
          final status = resData['data']['status'] as String? ?? 'completed';
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestResultsScreen(
                attemptId: attemptId,
                initialPending: status == 'pending',
                onRetake: () {
                  setState(() {
                    _currentIndex = 0;
                    _remainingSeconds = widget.totalDurationMinutes * 60;
                    _answers.clear();
                    _startedAt = DateTime.now();
                  });
                  _syncTextController();
                  Navigator.pop(context);
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submit failed (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit error: $e')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
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
          title: Text(widget.testTitle, style: TextStyle(color: AppTheme.primaryText(context))),
          backgroundColor: AppTheme.appBarBg(context),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No questions available for this test.\n(Speaking sections are skipped in the app for now.)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondaryText(context)),
            ),
          ),
        ),
      );
    }

    final q = _current!;
    final nextColor = AppTheme.isDark(context) ? Colors.blueAccent : const Color(0xFF0066F5);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.appBarBg(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.iconColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q ${_currentIndex + 1}/${_questions.length}',
              style: TextStyle(color: AppTheme.primaryText(context), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              _formattedTime(),
              style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (q.hasPassage || q.hasImage)
            IconButton(
              icon: Icon(_isPassageExpanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.iconColor(context)),
              onPressed: () => setState(() => _isPassageExpanded = !_isPassageExpanded),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (q.hasAudio) _buildAudioBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isPassageExpanded && (q.hasPassage || q.hasImage)) ...[
                          _buildContextPanel(context, q),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            _chip(q.typeLabel, AppTheme.tagBg(context), AppTheme.tagText(context)),
                            const SizedBox(width: 8),
                            _chip(q.sectionName, const Color(0xFFF1F5F9), const Color(0xFF64748B)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_currentIndex + 1}. ${q.text}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context),
                            height: 1.4,
                          ),
                        ),
                        if (q.wordLimitInstruction != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            q.wordLimitInstruction!,
                            style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildAnswerWidget(context, q),
                      ],
                    ),
                  ),
                ),
                _buildNavBar(context, nextColor),
              ],
            ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAudioBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.headphones, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Listening audio',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: _toggleAudio,
            icon: Icon(
              _isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: const Color(0xFF1D4ED8),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextPanel(BuildContext context, RuntimeQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.sectionName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText(context))),
          const SizedBox(height: 10),
          if (q.hasImage)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(q.imageUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
          if (q.hasPassage)
            Text(
              q.passageText,
              style: TextStyle(fontSize: 14, height: 1.6, color: AppTheme.primaryText(context).withValues(alpha: 0.85)),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(BuildContext context, RuntimeQuestion q) {
    switch (q.kind) {
      case QuestionKind.mcq:
        return SelectionEngineWidget(
          options: q.options,
          selectedAnswer: _answers[_currentIndex],
          onChanged: (v) => setState(() => _answers[_currentIndex] = v),
        );
      case QuestionKind.multiSelect:
        final selected = (_answers[_currentIndex] as List<String>?) ?? <String>[];
        return Column(
          children: q.options.map((opt) {
            final checked = selected.contains(opt);
            return CheckboxListTile(
              value: checked,
              title: Text(opt, style: TextStyle(color: AppTheme.primaryText(context), fontSize: 14)),
              onChanged: (v) {
                setState(() {
                  final next = List<String>.from(selected);
                  if (v == true) {
                    next.add(opt);
                  } else {
                    next.remove(opt);
                  }
                  _answers[_currentIndex] = next;
                });
              },
            );
          }).toList(),
        );
      case QuestionKind.trueFalseNg:
        return _pillRow(['True', 'False', 'Not Given']);
      case QuestionKind.yesNoNg:
        return _pillRow(['Yes', 'No', 'Not Given']);
      case QuestionKind.matching:
        final keys = q.matchingKeys.map((p) => p['key'] ?? '').where((k) => k.isNotEmpty).toList();
        final opts = q.options.isNotEmpty ? q.options : q.matchingKeys.map((p) => p['value'] ?? '').where((v) => v.isNotEmpty).toList();
        final selected = Map<String, String>.from(_answers[_currentIndex] as Map? ?? {});
        return MatchingEngineWidget(
          questionsToMatch: keys.isNotEmpty ? keys : [q.text],
          availableOptions: opts,
          selectedAnswers: selected,
          onOptionChanged: (question, option) {
            setState(() {
              final m = Map<String, String>.from(selected);
              m[question] = option;
              _answers[_currentIndex] = m;
            });
          },
        );
      case QuestionKind.writing:
        final text = (_answers[_currentIndex] as String?) ?? '';
        final wc = _wordCount(text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.inputFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor(context)),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 12,
                style: TextStyle(color: AppTheme.primaryText(context)),
                onChanged: (v) => setState(() => _answers[_currentIndex] = v),
                decoration: InputDecoration(
                  hintText: 'Write your response here…',
                  hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$wc words${q.minWords > 0 ? ' (min ${q.minWords})' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: q.minWords > 0 && wc < q.minWords ? Colors.orange : Colors.green.shade700,
              ),
            ),
          ],
        );
      default:
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.inputFill(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: TextField(
            controller: _textController,
            style: TextStyle(color: AppTheme.primaryText(context)),
            onChanged: (v) => setState(() => _answers[_currentIndex] = v),
            decoration: InputDecoration(
              hintText: 'Type your answer…',
              hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        );
    }
  }

  Widget _pillRow(List<String> options) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final selected = _answers[_currentIndex] == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: selected,
          onSelected: (_) => setState(() => _answers[_currentIndex] = opt),
          selectedColor: AppTheme.tagText(context),
          labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.primaryText(context)),
        );
      }).toList(),
    );
  }

  Widget _buildNavBar(BuildContext context, Color nextColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        border: Border(top: BorderSide(color: AppTheme.borderColor(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 0)
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _currentIndex--);
                _syncTextController();
              },
              icon: Icon(Icons.arrow_back, size: 16, color: AppTheme.primaryText(context)),
              label: Text('Prev', style: TextStyle(color: AppTheme.primaryText(context))),
            )
          else
            const SizedBox(width: 80),
          if (_currentIndex < _questions.length - 1)
            ElevatedButton(
              onPressed: () {
                setState(() => _currentIndex++);
                _syncTextController();
              },
              style: ElevatedButton.styleFrom(backgroundColor: nextColor),
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            )
          else
            ElevatedButton(
              onPressed: _confirmSubmit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Submit Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

/// Backward-compatible alias used by older imports.
typedef ReadingTestScreen = DynamicTestScreen;
