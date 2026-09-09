import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'premium_modal.dart';

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
    UserNotifier.notifier.addListener(_onUserChanged);
    _fetchLiveProgress();
  }

  @override
  void dispose() {
    UserNotifier.notifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  bool _isLocked(String track) {
    final user = UserNotifier.notifier.value;
    final unlocked = user['unlocked_exam']?.toString().toUpperCase();
    final isPremium = user['isPremium'] == true ||
        user['subscription'] == 'premium' ||
        unlocked == 'BOTH';
    if (isPremium || user['role'] == 'admin') return false;
    if (unlocked == 'IELTS' || unlocked == 'PTE') return unlocked != track;
    final pref = (user['preference'] ?? 'IELTS').toString().toUpperCase();
    return pref != track;
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
            _activeTrack = (UserNotifier.notifier.value['preference'] ?? 'IELTS')
                .toString()
                .toUpperCase();
            _isLoading = false;
          });
          return;
        }
      }
      _setEmptyProgress();
    } catch (e) {
      debugPrint(e.toString());
      _setEmptyProgress();
    }
  }

  void _setEmptyProgress() {
    if (mounted) {
      setState(() {
        _overallProgress = 0.0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int percentageDisplay = (_overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Keep going, you're doing great!",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.secondaryText(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 72,
                    width: 72,
                    child: CircularProgressIndicator(
                      value: _isLoading ? null : _overallProgress,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: AppTheme.brandBlue,
                    ),
                  ),
                  Text(
                    _isLoading ? '…' : '$percentageDisplay%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: AppTheme.brandBlue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _tabItem('IELTS', _activeTrack == 'IELTS', _isLocked('IELTS'), percentageDisplay),
              const SizedBox(width: 18),
              _tabItem('PTE', _activeTrack == 'PTE', _isLocked('PTE'), percentageDisplay),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool isActive, bool locked, int percent) {
    return GestureDetector(
      onTap: locked
          ? () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const PremiumModal(),
              );
            }
          : () => setState(() => _activeTrack = label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isActive && !locked)
                Text(
                  '$percent%  ',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.brandBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: isActive && !locked
                      ? AppTheme.brandBlue
                      : AppTheme.secondaryText(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (locked) ...[
                const SizedBox(width: 4),
                Icon(Icons.lock_outline, size: 12, color: AppTheme.secondaryText(context)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 44,
            decoration: BoxDecoration(
              color: isActive && !locked ? AppTheme.brandBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
