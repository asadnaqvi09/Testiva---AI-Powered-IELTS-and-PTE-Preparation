import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final bool isDarkMode;
  final Map<String, dynamic> userData;
  final VoidCallback? onEditPressed;
  final VoidCallback? onAvatarTap;
  final bool avatarUploading;

  const ProfileHeader({
    super.key,
    required this.isDarkMode,
    required this.userData,
    this.onEditPressed,
    this.onAvatarTap,
    this.avatarUploading = false,
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
    final avatarUrl = userData['avatar_url']?.toString();

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
          GestureDetector(
            onTap: avatarUploading ? null : onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(16),
                    image: avatarUrl != null && avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarUploading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              initials,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                ),
                if (onAvatarTap != null && !avatarUploading)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.cardBg(context),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
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
