import 'package:flutter/material.dart';
import 'premium_modal.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:frontend/core/services/user_notifier.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(int) onActionTap;

  const QuickActionsGrid({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: UserNotifier.notifier,
      builder: (context, user, child) {
        final String preference = user['preference'] ?? 'IELTS';
        final String? unlocked = user['unlocked_exam']?.toString();
        final bool isPremium = user['isPremium'] == true ||
            user['subscription'] == 'premium' ||
            unlocked?.toUpperCase() == 'BOTH';
        final bool isAdmin = user['role'] == 'admin';
        final bool hasAccessAll = isPremium || isAdmin;

        final unlockedUpper = unlocked?.toUpperCase();
        final bool canIelts = hasAccessAll ||
            unlockedUpper == 'IELTS' ||
            (unlockedUpper == null && preference.toUpperCase() == 'IELTS');
        final bool canPte = hasAccessAll ||
            unlockedUpper == 'PTE' ||
            (unlockedUpper == null && preference.toUpperCase() == 'PTE');

        final bool isIeltsLocked = !canIelts;
        final bool isPteLocked = !canPte;
        final String primaryTrack = (unlockedUpper == 'IELTS' || unlockedUpper == 'PTE')
            ? unlockedUpper!
            : preference.toUpperCase();
        final bool showIeltsPrimary = primaryTrack == 'IELTS';

        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '4 available',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.secondaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _actionCard(
                  context,
                  showIeltsPrimary ? 'Start Mock' : 'PTE Mock',
                  showIeltsPrimary ? 'IELTS Reading' : 'Start Mock Test',
                  Icons.description_outlined,
                  const Color(0xFF007BFF),
                  isLocked: false,
                  onTap: () => onActionTap(1),
                ),
                _actionCard(
                  context,
                  'Continue Prep',
                  isIeltsLocked ? 'Unlock Premium' : 'IELTS Writing',
                  Icons.menu_book_outlined,
                  isIeltsLocked ? const Color(0xFF94A3B8) : const Color(0xFF22C55E),
                  isLocked: isIeltsLocked,
                  onTap: () {
                    if (isIeltsLocked) {
                      _showPremium(context);
                    } else {
                      onActionTap(2);
                    }
                  },
                ),
                _actionCard(
                  context,
                  'Community',
                  'Discuss & learn',
                  Icons.people_outline,
                  const Color(0xFFF59E0B),
                  isLocked: false,
                  onTap: () => onActionTap(3),
                ),
                _actionCard(
                  context,
                  'PTE Prep',
                  isPteLocked ? 'Unlock Premium' : 'PTE Preparation',
                  Icons.track_changes,
                  isPteLocked ? const Color(0xFF94A3B8) : const Color(0xFF8B5CF6),
                  isLocked: isPteLocked,
                  onTap: () {
                    if (isPteLocked) {
                      _showPremium(context);
                    } else {
                      onActionTap(2);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPremium(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumModal(),
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color, {
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                if (isLocked)
                  Icon(Icons.lock_outline, size: 16, color: AppTheme.secondaryText(context)),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppTheme.primaryText(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.secondaryText(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
