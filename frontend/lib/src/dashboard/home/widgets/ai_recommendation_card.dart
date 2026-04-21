import 'package:flutter/material.dart';

class AIRecommendationCard extends StatelessWidget {
  const AIRecommendationCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF007BFF), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.lightbulb_outline, color: Colors.white70, size: 18),
          SizedBox(width: 8),
          Text("AI RECOMMENDATION", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        const Text("Focus on IELTS Writing Task 2", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Based on your recent mock scores, improving essay structure could boost your band by +0.5", style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: const Text("Start Writing Practice →", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}