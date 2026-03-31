// lib/src/onboarding/widgets/onboarding_header.dart
import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Testiva", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.5)),
              Text("AI-Powered IELTS\nand PTE Preparation",
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500, height: 1.2)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFE8F3FF), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.star, color: Color(0xFF007BFF), size: 14),
                SizedBox(width: 4),
                Text("4.9 Rating", style: TextStyle(color: Color(0xFF007BFF), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}