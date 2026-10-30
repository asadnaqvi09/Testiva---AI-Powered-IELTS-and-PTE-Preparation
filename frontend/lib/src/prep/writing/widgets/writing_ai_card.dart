import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';

/// Live tip from GET /ai/recommendation (falls back to short local tip).
class WritingAICard extends StatefulWidget {
  const WritingAICard({super.key});

  @override
  State<WritingAICard> createState() => _WritingAICardState();
}

class _WritingAICardState extends State<WritingAICard> {
  String _tip = 'Loading tip…';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  Future<void> _loadTip() async {
    try {
      final exam = (UserNotifier.notifier.value['preference'] ?? 'IELTS')
          .toString()
          .toUpperCase();
      final res = await ApiService.get('/ai/recommendation?exam_type=$exam');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final data = body['data'] ?? body;
          final tip = (data is Map
                  ? (data['tip'] ?? data['recommendation'] ?? data['message'])
                  : null)
              ?.toString();
          if (tip != null && tip.isNotEmpty) {
            if (mounted) setState(() { _tip = tip; _loading = false; });
            return;
          }
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _tip =
            'Plan Task 2 with intro → 2 body paragraphs → short conclusion before you write.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007BFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'AI TIP',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          else
            Text(
              _tip,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
