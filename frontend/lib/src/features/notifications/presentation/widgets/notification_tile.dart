import 'package:flutter/material.dart';
import 'package:frontend/data/models/notification_model.dart';
import 'package:frontend/widgets/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  static IconData _iconForType(String type) {
    switch (type) {
      case 'post_like':
        return Icons.favorite_outline;
      case 'post_comment':
        return Icons.chat_bubble_outline;
      case 'comment_reply':
        return Icons.reply_outlined;
      case 'post_flagged':
        return Icons.flag_outlined;
      case 'post_unflagged':
        return Icons.check_circle_outline;
      case 'post_deleted':
        return Icons.delete_outline;
      case 'preference_new_post':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'post_like':
        return const Color(0xFFE11D48);
      case 'post_comment':
      case 'comment_reply':
        return const Color(0xFF007BFF);
      case 'post_flagged':
      case 'post_deleted':
        return const Color(0xFFDC3545);
      case 'post_unflagged':
        return const Color(0xFF28A745);
      case 'preference_new_post':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  static String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _colorForType(notification.type);
    final icon = _iconForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material(
        color: notification.isRead
            ? AppTheme.cardBg(context)
            : const Color(0xFF007BFF).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor(context)),
              boxShadow: AppTheme.cardShadow(context),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primaryText(context),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF007BFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryText(context),
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _timeAgo(notification.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryText(context),
                            ),
                          ),
                          if (notification.sender != null) ...[
                            Text(
                              ' · ',
                              style: TextStyle(color: AppTheme.secondaryText(context)),
                            ),
                            Flexible(
                              child: Text(
                                notification.sender!.fullName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF007BFF),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (notification.isCommunityRelated) ...[
                            const Spacer(),
                            Text(
                              'View post',
                              style: TextStyle(
                                fontSize: 11,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
