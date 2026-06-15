import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class TestResultsScreen extends StatefulWidget {
  final String attemptId;
  final VoidCallback onRetake;
  final VoidCallback onAllTestsPressed;

  const TestResultsScreen({
    super.key,
    required this.attemptId,
    required this.onRetake,
    required this.onAllTestsPressed,
  });

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  Map<String, dynamic>? _resultData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.get('/progress/result/${widget.attemptId}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          setState(() {
            _resultData = body['data'] as Map<String, dynamic>;
          });
        }
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _resultData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_resultData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Test Results'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('Failed to load test results.')),
      );
    }

    // Safely Extracting Maps with Fallbacks to Prevent Crashes
    final mainInfo = _resultData!['main_info'] as Map<String, dynamic>? ?? {};
    final stats = _resultData!['stats'] as Map<String, dynamic>? ?? {};
    final scoresBreakdown = _resultData!['scores_breakdown'] as Map<String, dynamic>? ?? {};
    final aiAnalysis = _resultData!['ai_analysis'] as Map<String, dynamic>? ?? {};
    final reviewList = _resultData!['review'] as List? ?? [];

    final double bandScore = _parseDouble(mainInfo['band_score']);
    final int correctCount = _parseInt(stats['correct_answers']);
    final int totalQuestions = _parseInt(stats['total_questions']);
    final int incorrectCount = totalQuestions - correctCount;
    final String accuracyString = stats['accuracy']?.toString() ?? '0%';
    final double accuracyValue = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;

    // Module Scores Null-Safety Parsing
    final double rScore = _parseDouble(scoresBreakdown['reading']);
    final double lScore = _parseDouble(scoresBreakdown['listening']);
    final double wScore = _parseDouble(scoresBreakdown['writing']);
    final double sScore = _parseDouble(scoresBreakdown['speaking']);

    // AI Feedback Text Setup
    String dynamicAiFeedback = aiAnalysis['feedback'] as String? ?? '';
    if (dynamicAiFeedback.isEmpty) {
      if (aiAnalysis['strengths'] != null || aiAnalysis['weaknesses'] != null) {
        dynamicAiFeedback = "Strengths: ${aiAnalysis['strengths'] ?? 'Good effort'}\nWeaknesses: ${aiAnalysis['weaknesses'] ?? 'None'}";
      } else {
        dynamicAiFeedback = 'Good job! Review incorrect answers carefully.';
      }
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
        title: const Text(
          'Test Results',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0066F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('ESTIMATED BAND SCORE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('$bandScore', style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(bandScore >= 6.0 ? '📊 Competent User' : '📊 Limited User', style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                      _buildScoreStat(accuracyString, 'Score'),
                    ],
                  )
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
                  _buildBreakdownRow('Accuracy', accuracyValue, accuracyString, Colors.blue),
                  _buildBreakdownRow('Reading', rScore / 9.0, 'Band $rScore', Colors.purple),
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
                  Text(
                    dynamicAiFeedback,
                    style: const TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.4),
                  ),
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
                  var q = reviewList[index] as Map<String, dynamic>;
                  bool isCorrect = q['is_correct'] as bool? ?? false;
                  String userAns = q['your_answer']?.toString() ?? '';

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
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isCorrect ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6),
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                size: 14,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Q${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                        child: Text(q['type'] as String? ?? 'Reading', style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(q['question'] as String? ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Text(
                          'Your response: ${userAns.trim().isNotEmpty ? userAns : "Not Answered"}',
                          style: TextStyle(color: userAns.trim().isNotEmpty ? Colors.grey.shade700 : Colors.red.shade400, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Correct response: ${q['correct_answer'] ?? "N/A"}',
                          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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