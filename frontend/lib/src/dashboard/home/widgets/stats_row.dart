import 'package:flutter/material.dart';
import '../../../../widgets/stats_card.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        // Individual boxes ki jagah global widget call kiya
        Expanded(
          child: GlobalStatsCard(
            isDarkMode: false,
            value: "3",
            label: "Day Streak",
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GlobalStatsCard(
            isDarkMode: false,
            value: "6.5",
            label: "Est. Band",
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GlobalStatsCard(
            isDarkMode: false,
            value: "5",
            label: "Tests Done",
            icon: Icons.trending_up,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}