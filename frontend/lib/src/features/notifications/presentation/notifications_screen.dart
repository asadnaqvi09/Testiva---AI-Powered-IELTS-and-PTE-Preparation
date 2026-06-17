import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/data/models/notification_model.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:frontend/src/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh();
    });
  }

  Future<void> _handleTap(NotificationModel notification) async {
    final provider = context.read<NotificationProvider>();
    await provider.markAsRead(notification.id);

    if (!mounted) return;

    if (notification.isCommunityRelated) {
      provider.requestCommunityNavigation(postId: notification.postId);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    if (notification.type == 'post_flagged' ||
        notification.type == 'post_deleted' ||
        notification.type == 'post_unflagged') {
      provider.requestCommunityNavigation();
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBg(context),
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.primaryText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.iconColor(context)),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.loading ? null : () => provider.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF007BFF),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF007BFF),
        onRefresh: provider.refresh,
        child: provider.loading && provider.notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator(color: Color(0xFF007BFF))),
                ],
              )
            : provider.notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Icon(Icons.notifications_none,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(
                            color: AppTheme.secondaryText(context),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Likes, comments, and community updates will appear here',
                          style: TextStyle(
                            color: AppTheme.secondaryText(context),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notification = provider.notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _handleTap(notification),
                        onDismiss: () => provider.deleteNotification(notification.id),
                      );
                    },
                  ),
      ),
    );
  }
}
