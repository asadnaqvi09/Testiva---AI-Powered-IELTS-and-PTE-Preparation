import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../widgets/stats_card.dart';

class StatsRow extends StatefulWidget {
  const StatsRow({super.key});

  @override
  State<StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<StatsRow> {
  bool _isLoading = true;

  static const _cacheKey = 'cached_my_stats_row';

  String _dayStreak = '0';
  String _estBand = '0.0';
  String _testsDone = '0';

  @override
  void initState() {
    super.initState();
    _fetchLiveDashboardStats();
  }

  void _apply(Map stats) {
    setState(() {
      _dayStreak = (stats['dayStreak'] ?? stats['streak_days'] ?? '0').toString();
      _estBand = (stats['average_band_score'] ?? '0.0').toString();
      _testsDone = (stats['total_tests_taken'] ?? '0').toString();
      _isLoading = false;
    });
  }

  Future<void> _fetchLiveDashboardStats() async {
    // This is a comment: last-known stats cache for offline home
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        final map = jsonDecode(cached);
        if (map is Map) _apply(Map<String, dynamic>.from(map));
      }
    } catch (_) {}

    try {
      final response = await ApiService.get('/progress/my-stats');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final stats = data['data'] as Map;
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_cacheKey, jsonEncode(stats));
          } catch (_) {}
          if (mounted) _apply(Map<String, dynamic>.from(stats));
          return;
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Day Streak Card
        Expanded(
          child: GlobalStatsCard(
            value: _isLoading ? '...' : _dayStreak,
            line1: 'Day',
            line2: 'Streak',
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),

        // 2. Est. Band Card
        Expanded(
          child: GlobalStatsCard(
            value: _isLoading ? '...' : _estBand,
            line1: 'Est.',
            line2: 'Band',
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),

        // 3. Tests Done Card
        Expanded(
          child: GlobalStatsCard(
            value: _isLoading ? '...' : _testsDone,
            line1: 'Tests',
            line2: 'Done',
            icon: Icons.trending_up,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}