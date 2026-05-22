import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService ka path check kar lein
import '../../../../widgets/stats_card.dart'; // Aapke original import ko maintain rakha hai

class StatsRow extends StatefulWidget {
  const StatsRow({super.key});

  @override
  State<StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<StatsRow> {
  bool _isLoading = true;

  // Real-time server state variables (Defaults set hain taake server error par UI kharab na ho)
  String _dayStreak = '3';
  String _estBand = '6.5';
  String _testsDone = '5';

  @override
  void initState() {
    super.initState();
    _fetchLiveDashboardStats();
  }

  // 🚀 Live Backend progress endpoint data wiring
  Future<void> _fetchLiveDashboardStats() async {
    try {
      final response = await ApiService.get('/progress');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final stats = data['data'];
          setState(() {
            // Backend responses se values pick ho rahi hain (with proper casting string fallback)
            _dayStreak = (stats['dayStreak'] ?? stats['streak_days'] ?? '3').toString();
            _estBand = (stats['estBand'] ?? stats['average_score'] ?? '6.5').toString();
            _testsDone = (stats['testsDone'] ?? stats['total_tests'] ?? '5').toString();
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false); // Fallback variables already initialized hain
    } catch (e) {
      debugPrint("Error loading stats row server data: ${e.toString()}");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Day Streak Card
        Expanded(
          child: GlobalStatsCard(
            isDarkMode: isDarkMode,
            value: _isLoading ? '...' : _dayStreak,
            label: 'Day Streak',
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),

        // 2. Est. Band Card
        Expanded(
          child: GlobalStatsCard(
            isDarkMode: isDarkMode,
            value: _isLoading ? '...' : _estBand,
            label: 'Est. Band',
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),

        // 3. Tests Done Card
        Expanded(
          child: GlobalStatsCard(
            isDarkMode: isDarkMode,
            value: _isLoading ? '...' : _testsDone,
            label: 'Tests Done',
            icon: Icons.trending_up,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}