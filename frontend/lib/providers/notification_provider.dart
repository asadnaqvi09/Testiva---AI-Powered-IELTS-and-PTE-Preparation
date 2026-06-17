import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/notification_service.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;
  bool _initialized = false;
  int? pendingDashboardTab;
  String? pendingPostId;

  final Set<String> _seenIds = {};

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    await refresh();
    await _connectSocket();
    _initialized = true;
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        NotificationService.fetchNotifications(),
        NotificationService.fetchUnreadCount(),
      ]);
      _notifications
        ..clear()
        ..addAll(results[0] as List<NotificationModel>);
      _unreadCount = results[1] as int;
      _seenIds
        ..clear()
        ..addAll(_notifications.map((n) => n.id));
    } catch (e) {
      debugPrint('[Notifications] Refresh failed: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _connectSocket() async {
    await socketService.connect();

    void handleNew(dynamic data) {
      if (data is! Map) return;
      final raw = data['notification'];
      if (raw is! Map) return;

      try {
        final notification = NotificationModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
        if (_seenIds.contains(notification.id)) return;

        _seenIds.add(notification.id);
        _notifications.insert(0, notification);

        if (data['unreadCount'] is int) {
          _unreadCount = data['unreadCount'] as int;
        } else if (!notification.isRead) {
          _unreadCount += 1;
        }

        notifyListeners();
      } catch (e) {
        debugPrint('[Notifications] Socket parse error: $e');
      }
    }

    void attach() {
      socketService.off('notification:new', handleNew);
      socketService.on('notification:new', handleNew);
    }

    attach();
    socketService.onConnect(attach);
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (_notifications[index].isRead) return;

    _notifications[index] = NotificationModel(
      id: _notifications[index].id,
      type: _notifications[index].type,
      title: _notifications[index].title,
      message: _notifications[index].message,
      isRead: true,
      createdAt: _notifications[index].createdAt,
      postId: _notifications[index].postId,
      commentId: _notifications[index].commentId,
      sender: _notifications[index].sender,
    );
    _unreadCount = (_unreadCount - 1).clamp(0, 999);
    notifyListeners();

    try {
      _unreadCount = await NotificationService.markAsRead(id);
      notifyListeners();
    } catch (e) {
      debugPrint('[Notifications] markAsRead failed: $e');
      await refresh();
    }
  }

  Future<void> markAllAsRead() async {
    if (_unreadCount == 0) return;
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if (!n.isRead) {
        _notifications[i] = NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
          postId: n.postId,
          commentId: n.commentId,
          sender: n.sender,
        );
      }
    }
    _unreadCount = 0;
    notifyListeners();

    try {
      _unreadCount = await NotificationService.markAllAsRead();
      notifyListeners();
    } catch (e) {
      debugPrint('[Notifications] markAllAsRead failed: $e');
      await refresh();
    }
  }

  Future<void> deleteNotification(String id) async {
    final removed = _notifications.firstWhere((n) => n.id == id);
    _notifications.removeWhere((n) => n.id == id);
    if (!removed.isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
    }
    _seenIds.remove(id);
    notifyListeners();

    try {
      _unreadCount = await NotificationService.deleteNotification(id);
      notifyListeners();
    } catch (e) {
      debugPrint('[Notifications] delete failed: $e');
      await refresh();
    }
  }

  void requestCommunityNavigation({String? postId}) {
    pendingDashboardTab = 3;
    pendingPostId = postId;
    notifyListeners();
  }

  void clearPendingNavigation() {
    pendingDashboardTab = null;
    pendingPostId = null;
  }

  void reset() {
    socketService.disconnect();
    _notifications.clear();
    _seenIds.clear();
    _unreadCount = 0;
    _loading = false;
    _initialized = false;
    clearPendingNavigation();
    notifyListeners();
  }
}
