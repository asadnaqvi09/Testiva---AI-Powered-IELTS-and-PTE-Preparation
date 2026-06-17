import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/widgets/app_theme.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key});

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool _isLoading = true;
  double _overallProgress = 0.0;
  String _activeTrack = 'IELTS';

  @override
  void initState() {
    super.initState();
    _fetchLiveProgress();
  }

  Future<void> _fetchLiveProgress() async {
    try {
      final response = await ApiService.get('/progress/my-stats');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final stats = data['data'];
          setState(() {
            double totalTaken = (stats['total_tests_taken'] ?? 0).toDouble();
            double bandScore = double.tryParse((stats['average_band_score'] ?? 0.0).toString()) ?? 0.0;
            _overallProgress = totalTaken > 0 ? (bandScore / 9.0).clamp(0.0, 1.0) : 0.0;
            _activeTrack = 'IELTS';
            _isLoading = false;
          });
          return;
        }
      }
      _loadFallbackData();
    } catch (e) {
      debugPrint(e.toString());
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    if (mounted) {
      setState(() {
        _overallProgress = 0.65;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    int percentageDisplay = (_overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                Text(
                  "Keep going, you're doing great!",
                  style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 13),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    // Tab automatically highlight ho jayenge jo backend track data return karega
                    _tabItem(context, 'IELTS', _activeTrack.toUpperCase() == 'IELTS'),
                    const SizedBox(width: 10),
                    _tabItem(context, 'PTE', _activeTrack.toUpperCase() == 'PTE'),
                  ],
                )
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80, width: 80,
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.tagBg(context)),
                  strokeWidth: 4,
                )
                    : CircularProgressIndicator(
                  value: _overallProgress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.tagBg(context),
                  color: AppTheme.tagText(context),
                ),
              ),
              _isLoading
                  ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.tagText(context))
              )
                  : Text(
                  '$percentageDisplay%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tagText(context),
                    fontSize: 16,
                  )
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tabItem(BuildContext context, String label, bool isActive) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isActive ? AppTheme.tagBg(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
        label,
        style: TextStyle(
            color: isActive ? AppTheme.tagText(context) : AppTheme.secondaryText(context),
            fontWeight: FontWeight.bold,
            fontSize: 12
        )
    ),
  );
}