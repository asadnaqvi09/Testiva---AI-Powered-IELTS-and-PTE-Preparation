import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat("3", "Day Streak", Icons.local_fire_department, Colors.orange),
        const SizedBox(width: 12),
        _stat("6.5", "Est. Band", Icons.workspace_premium_outlined, Colors.green),
        const SizedBox(width: 12),
        _stat("5", "Tests Done", Icons.trending_up, Colors.blue),
      ],
    );
  }

  Widget _stat(String v, String l, IconData i, Color c) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: c, size: 24),
        const SizedBox(height: 8),
        Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    ),
  );
}