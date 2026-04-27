import 'package:flutter/material.dart';
import 'edit_profile_modal.dart';

class ProfileHeader extends StatelessWidget {
  final bool isDarkMode;
  const ProfileHeader({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF007BFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("AK",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ahmed Khan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black)),
            const Text("freeuser@example.com",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.grey),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const EditProfileModal(),
            );
          },
        ),
      ],
    );
  }
}