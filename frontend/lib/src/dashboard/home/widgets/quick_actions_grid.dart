import 'package:flutter/material.dart';
import 'premium_modal.dart';

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
        _actionCard('Start Mock', 'IELTS Reading', Icons.description_outlined, Colors.blue,
            onTap: () => onActionTap(1)),
        _actionCard('Continue Prep', 'IELTS Writing', Icons.menu_book_outlined, Colors.green,
            onTap: () => onActionTap(2)),
        _actionCard('Community', '3 new replies', Icons.people_outline, Colors.orange,
            onTap: () => onActionTap(3)),

        // PTE Prep Card
        _actionCard(
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

  Widget _actionCard(String title, String sub, IconData icon, Color color, {bool isLocked = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: color),
            if (isLocked) const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
          ]),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ]),
      ),
    );
  }
}