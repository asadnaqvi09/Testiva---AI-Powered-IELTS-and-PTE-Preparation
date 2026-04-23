import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

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
        _actionCard("Start Mock", "IELTS Reading", Icons.description_outlined, Colors.blue),
        _actionCard("Continue Prep", "IELTS Writing", Icons.menu_book_outlined, Colors.green),
        _actionCard("Community", "3 new replies", Icons.people_outline, Colors.orange),
        _actionCard("PTE Prep", "Unlock Premium", Icons.track_changes, Colors.grey, isLocked: true),
      ],
    );
  }

  Widget _actionCard(String title, String sub, IconData icon, Color color, {bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              if (isLocked) const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}