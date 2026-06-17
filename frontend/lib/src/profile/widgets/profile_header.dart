import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  // isDarkMode kept for backward compatibility — uses AppTheme internally now
  final bool isDarkMode;
  final Map<String, dynamic> userData;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.isDarkMode,
    required this.userData,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String name = userData['name'] ?? 'User Name';
    final String email = userData['email'] ?? 'user@email.com';
    final bool isPremium = userData['isPremium'] ?? false;

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
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.secondaryText(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (onEditPressed != null)
                    GestureDetector(
                      onTap: onEditPressed,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007BFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Color(0xFF007BFF),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}