import 'package:flutter/material.dart';
import '../../../profile/profile_screen.dart';

class HeaderSection extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HeaderSection({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => scaffoldKey.currentState?.openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.menu, size: 20),
              ),
            ),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text('Testiva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF007BFF),
                child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tuesday, April 28', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 4),
            Row(
              children: [
                Text('Hello, Ahmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
            Text('Keep up the great work!', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 20),
        _premiumBanner(),
      ],
    );
  }

  Widget _premiumBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF9E7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFE58F)),
    ),
    child: const Row(
      children: [
        Icon(Icons.workspace_premium_outlined, color: Color(0xFFD48806), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Unlock IELTS & PTE - Get Premium',
            style: TextStyle(color: Color(0xFF874D00), fontWeight: FontWeight.w600),
          ),
        ),
        Icon(Icons.chevron_right, color: Color(0xFFD48806)),
      ],
    ),
  );
}