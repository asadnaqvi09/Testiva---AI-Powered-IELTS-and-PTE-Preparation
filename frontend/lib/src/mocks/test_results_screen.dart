import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'models/runtime_question.dart';

class TestResultsScreen extends StatefulWidget {
  final String attemptId;
  final bool initialPending;
  final VoidCallback onRetake;
  final VoidCallback onAllTestsPressed;

  const TestResultsScreen({
    super.key,
    required this.attemptId,
    this.initialPending = false,
    required this.onRetake,
    required this.onAllTestsPressed,
  });

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  Map<String, dynamic>? _resultData;
  bool _isLoading = false;
  bool _isPending = false;
  Timer? _pollTimer;
  int _pollCount = 0;

  @override
  void initState() {
    super.initState();
    _isPending = widget.initialPending;
    _fetchResults();
    if (_isPending) _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pollCount >= 30) {
        _pollTimer?.cancel();
        return;
      }
      _pollCount++;
      _fetchResults(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchResults({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/progress/result/${widget.attemptId}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'] as Map<String, dynamic>;
          final status = (data['main_info'] as Map?)?['status']?.toString() ?? '';
          final pending = status == 'pending' || status == 'in_progress';
          if (mounted) {
            setState(() {
              _resultData = data;
              _isPending = pending;
            });
          }
          if (!pending) _pollTimer?.cancel();
        }
      }
    } catch (_) {}
    if (mounted && !silent) setState(() => _isLoading = false);
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _formatAnswer(dynamic ans) {
    if (ans == null) return '';
    if (ans is String) return ans;
    if (ans is Map && ans['text_essay'] != null) return ans['text_essay'].toString();
    if (ans is List) return ans.join(', ');
    return ans.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _resultData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_resultData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load results.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchResults, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final mainInfo = _resultData!['main_info'] as Map<String, dynamic>? ?? {};
    final stats = _resultData!['stats'] as Map<String, dynamic>? ?? {};
    final scoresBreakdown = _resultData!['scores_breakdown'] as Map<String, dynamic>? ?? {};
    final aiAnalysis = _resultData!['ai_analysis'] as Map<String, dynamic>? ?? {};
    final reviewList = _resultData!['review'] as List? ?? [];

    final double bandScore = _parseDouble(mainInfo['band_score']);
    final int correctCount = _parseInt(stats['correct_answers']);
    final int totalQuestions = _parseInt(stats['total_questions']);
    final int incorrectCount = totalQuestions - correctCount;
    final int marksObtained = _parseInt(stats['marks_obtained']);
    final int totalMarks = _parseInt(stats['total_marks']);
    final String accuracyString = stats['accuracy']?.toString() ?? '0%';
    final String marksString = totalMarks > 0 ? '$marksObtained/$totalMarks' : '$marksObtained';
    final double accuracyValue = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;

    final double rScore = _parseDouble(scoresBreakdown['reading']);
    final double lScore = _parseDouble(scoresBreakdown['listening']);
    final double wScore = _parseDouble(scoresBreakdown['writing']);
    final double sScore = _parseDouble(scoresBreakdown['speaking']);

    String aiFeedback = aiAnalysis['feedback'] as String? ?? '';
    if (aiFeedback.isEmpty) {
      aiFeedback = 'Review your answers below for detailed feedback.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Test Results', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchResults),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isPending)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI is evaluating your writing responses. Scores will update automatically…',
                        style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0066F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    _isPending ? 'PRELIMINARY SCORE' : 'ESTIMATED BAND SCORE',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text('$bandScore', style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    mainInfo['test_title']?.toString() ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreStat('$correctCount', 'Correct'),
                      Container(height: 30, width: 1, color: Colors.white24),
                      _buildScoreStat('$incorrectCount', 'Incorrect'),
                      Container(height: 30, width: 1, color: Colors.white24),
                      _buildScoreStat(marksString, 'Marks'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Performance Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 16),
                  if (totalQuestions > 0) _buildBreakdownRow('Accuracy', accuracyValue, accuracyString, Colors.blue),
                  if (rScore > 0 || totalQuestions > 0) _buildBreakdownRow('Reading', rScore / 9.0, 'Band $rScore', Colors.purple),
                  if (lScore > 0) _buildBreakdownRow('Listening', lScore / 9.0, 'Band $lScore', Colors.green),
                  if (wScore > 0) _buildBreakdownRow('Writing', wScore / 9.0, 'Band $wScore', Colors.orange),
                  if (sScore > 0) _buildBreakdownRow('Speaking', sScore / 9.0, 'Band $sScore', Colors.pink),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF5FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD0E4FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFF0066F5), size: 20),
                      SizedBox(width: 8),
                      Text('AI FEEDBACK', style: TextStyle(color: Color(0xFF0066F5), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(aiFeedback, style: const TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (reviewList.isNotEmpty) ...[
              const Text('Question Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviewList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final q = reviewList[index] as Map<String, dynamic>;
                  final isCorrect = q['is_correct'] as bool? ?? false;
                  final isAi = q['is_correct'] == null;
                  final userAns = _formatAnswer(q['your_answer']);
                  final typeRaw = q['sub_type']?.toString() ?? q['type']?.toString() ?? '';
                  final typeLabel = TestRuntimeParser.chipLabel(typeRaw.isNotEmpty ? typeRaw : (q['type']?.toString() ?? ''));

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isAi
                                  ? const Color(0xFFFFF7ED)
                                  : isCorrect
                                      ? const Color(0xFFE6F4EA)
                                      : const Color(0xFFFCE8E6),
                              child: Icon(
                                isAi ? Icons.psychology : isCorrect ? Icons.check : Icons.close,
                                size: 14,
                                color: isAi ? Colors.orange : isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Q${q['q_no'] ?? index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                        child: Text(typeLabel, style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(q['question'] as String? ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Text(
                          'Your response: ${userAns.trim().isNotEmpty ? userAns : "Not answered"}',
                          style: TextStyle(color: userAns.trim().isNotEmpty ? Colors.grey.shade700 : Colors.red.shade400, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        if (!isAi && q['correct_answer'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Correct: ${q['correct_answer']}',
                            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                        if (q['ai_feedback_per_question'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            q['ai_feedback_per_question'].toString(),
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: widget.onRetake,
                      icon: const Icon(Icons.refresh, color: Colors.black87, size: 18),
                      label: const Text('Retake', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: widget.onAllTestsPressed,
                      icon: const Icon(Icons.grid_view, color: Colors.white, size: 18),
                      label: const Text('All Tests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066F5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildBreakdownRow(String title, double progressValue, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(percentage, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
