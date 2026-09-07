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

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.1,
          children: [
            // Start Mock (matches unlocked / preference track)
            _actionCard(
              context,
              showIeltsPrimary ? 'Start Mock' : 'PTE Mock',
              showIeltsPrimary ? 'IELTS Reading' : 'Start Mock Test',
              Icons.description_outlined,
              Colors.blue,
              isLocked: false,
              onTap: () => onActionTap(1),
            ),
            
            // IELTS Prep Card
            _actionCard(
              context,
              'IELTS Prep',
              isIeltsLocked ? 'Unlock Premium' : 'IELTS Writing',
              Icons.menu_book_outlined,
              isIeltsLocked ? const Color(0xFF94A3B8) : Colors.green,
              isLocked: isIeltsLocked,
              onTap: () {
                if (isIeltsLocked) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const PremiumModal(),
                  );
                } else {
                  onActionTap(2);
                }
              },
            ),

            // Community Card (unlocked)
            _actionCard(
              context,
              'Community',
              'Discuss & learn',
              Icons.people_outline,
              Colors.orange,
              isLocked: false,
              onTap: () => onActionTap(3),
            ),

            // PTE Prep Card
            _actionCard(
              context,
              'PTE Prep',
              isPteLocked ? 'Unlock Premium' : 'PTE Preparation',
              Icons.track_changes,
              isPteLocked ? const Color(0xFF94A3B8) : Colors.purple,
              isLocked: isPteLocked,
              onTap: () {
                if (isPteLocked) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const PremiumModal(),
                  );
                } else {
                  onActionTap(2);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _actionCard(BuildContext context, String title, String sub, IconData icon, Color color, {bool isLocked = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: color),
            if (isLocked) Icon(Icons.lock_outline, size: 16, color: AppTheme.secondaryText(context)),
          ]),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.primaryText(context),
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: AppTheme.secondaryText(context),
              fontSize: 12,
            ),
          ),
        ]),
      ),
    );
  }
}