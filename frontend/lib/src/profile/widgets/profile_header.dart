import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final bool isDarkMode;
  final Map<String, dynamic> userData;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.isDarkMode,
    required this.userData,
    this.onEditPressed,
  });

  String _memberSince(String? created) {
    if (created == null || created.isEmpty) return 'Member since January 2025';
    try {
      final dt = DateTime.parse(created);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Member since $created';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = userData['name'] ?? 'User Name';
    final String email = userData['email'] ?? 'user@email.com';
    final bool isPremium = userData['isPremium'] ?? false;
    final created = userData['created_at']?.toString();

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF475569),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPremium ? 'Premium' : 'Free',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: isPremium ? const Color(0xFFD97706) : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.secondaryText(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.secondaryText(context)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _memberSince(created),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
