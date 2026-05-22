import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final bool isDarkMode;
  final Map<String, dynamic> userData;

  const ProfileHeader({
    super.key,
    required this.isDarkMode,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract values with safe defaults to prevent runtime null pointer crashes
    final String name = userData['name'] ?? 'User Name';
    final String email = userData['email'] ?? 'user@email.com';
    final bool isPremium = userData['isPremium'] ?? false;

    // Generate Initials for the Avatar (e.g., "Ali Khan" -> "AK")
    String initials = 'U';
    try {
      List<String> parts = name.trim().split(' ');
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    } catch (e) {
      initials = 'U';
    }

    return Row(
      children: [
        // Dynamic Initials Avatar Circle
        CircleAvatar(
          radius: 35,
          backgroundColor: const Color(0xFF007BFF),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 15),

        // User Text Meta Information Fields
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Premium Tier Badge Indicator Status Switcher
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFF59E0B).withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPremium ? 'PREMIUM' : 'FREE TIER',
                      style: TextStyle(
                        color: isPremium ? const Color(0xFFD97706) : Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}