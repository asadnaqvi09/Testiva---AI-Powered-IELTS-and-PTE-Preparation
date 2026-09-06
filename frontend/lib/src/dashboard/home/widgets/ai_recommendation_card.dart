import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';

class AIRecommendationCard extends StatefulWidget {
  final VoidCallback onStartTap;

  const AIRecommendationCard({
    super.key,
    required this.onStartTap,
  });

  @override
  State<AIRecommendationCard> createState() => _AIRecommendationCardState();
}

class _AIRecommendationCardState extends State<AIRecommendationCard> {
  String _title = 'Loading recommendation…';
  String _body = 'Fetching a study focus based on your recent activity.';
  String _cta = 'Open Prep →';
  bool _isSample = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    final preference =
        (UserNotifier.notifier.value['preference']?.toString() ?? 'IELTS')
            .toUpperCase();
    try {
      final response =
          await ApiService.get('/ai/recommendation?exam_type=$preference');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['tip'] != null) {
          final focus = body['focus_module']?.toString();
          final reason = body['reason']?.toString();
          final source = body['source']?.toString();
          if (!mounted) return;
          setState(() {
            _title = focus != null && focus.isNotEmpty
                ? 'Focus on $preference $focus'
                : 'Study focus for $preference';
            _body = reason != null && reason.isNotEmpty
                ? '$reason\n\n${body['tip']}'
                : body['tip'].toString();
            _cta = focus != null ? 'Practice $focus →' : 'Open Prep →';
            _isSample = source == 'fallback';
            _loading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _title = 'Sample tip · $preference Writing';
      _body =
          'Practice essay structure and clear topic sentences. '
          'Personalized AI focus unlocks after you complete a few mock sections.';
      _cta = 'Start Prep →';
      _isSample = true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF007BFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                _isSample ? 'SAMPLE STUDY TIP' : 'STUDY FOCUS',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    setState(() => _loading = true);
                    _loadRecommendation();
                  },
                  child: const Icon(Icons.refresh, color: Colors.white54, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onStartTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              _cta,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
