import 'package:flutter/material.dart';

class DailyTipsList extends StatelessWidget {
  const DailyTipsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Daily Tips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
                onPressed: () {},
                child: const Text("See all", style: TextStyle(color: Color(0xFF007BFF)))
            ),
          ],
        ),
        const SizedBox(height: 10),
        _tipCard(
            "Reading Tip",
            "Practice skimming passages in under 2 minutes to improve reading speed and comprehension.",
            Icons.menu_book,
            const Color(0xFFE3F2FD),
            const Color(0xFF007BFF)
        ),
        const SizedBox(height: 15),
        _tipCard(
            "Listening Strategy",
            "Listen to BBC World Service daily to improve accent recognition for IELTS Listening.",
            Icons.headphones,
            const Color(0xFFFFF8E1),
            const Color(0xFFFFA000)
        ),
        const SizedBox(height: 15),
        _tipCard(
            "Writing Boost",
            "Use linking phrases like 'furthermore', 'however' and 'in contrast' to improve cohesion score.",
            Icons.edit_note,
            const Color(0xFFE8F5E9),
            const Color(0xFF43A047)
        ),
        const SizedBox(height: 15),
        _tipCard(
            "Speaking Practice",
            "Record yourself speaking for 2 minutes on random topics. Review for fluency and vocabulary.",
            Icons.interpreter_mode,
            const Color(0xFFF3E5F5),
            const Color(0xFF8E24AA)
        ),
      ],
    );
  }

  Widget _tipCard(String title, String desc, IconData icon, Color bg, Color iconCol) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconCol, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                  desc,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 13, height: 1.4)
              ),
            ],
          ),
        ),
      ],
    ),
  );
}