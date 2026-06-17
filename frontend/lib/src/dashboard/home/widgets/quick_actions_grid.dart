import 'package:flutter/material.dart';
import 'premium_modal.dart';
import 'package:frontend/widgets/app_theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(int) onActionTap;

  const QuickActionsGrid({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _actionCard(context, 'Start Mock', 'IELTS Reading', Icons.description_outlined, Colors.blue,
            onTap: () => onActionTap(1)),
        _actionCard(context, 'Continue Prep', 'IELTS Writing', Icons.menu_book_outlined, Colors.green,
            onTap: () => onActionTap(2)),
        _actionCard(context, 'Community', '3 new replies', Icons.people_outline, Colors.orange,
            onTap: () => onActionTap(3)),

        // PTE Prep Card
        _actionCard(
            context,
            'PTE Prep',
            'Unlock Premium',
            Icons.track_changes,
            const Color(0xFF94A3B8),
            isLocked: true,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const PremiumModal(),
              );
            }
        ),
      ],
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