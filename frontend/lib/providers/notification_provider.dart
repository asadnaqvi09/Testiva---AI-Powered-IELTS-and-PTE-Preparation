import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/fcm_token_service.dart';
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
  bool pendingOpenAllTests = false;
  String? pendingAttemptId;

  final Set<String> _seenIds = {};
  void Function(dynamic)? _socketHandler;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
    await _connectSocket(force: true);
    // clean and optimized code — sync FCM after inbox is live
    unawaited(FcmTokenService.syncTokenIfAvailable());
    FcmTokenService.onForegroundMessage = _onForegroundPush;
    FcmTokenService.onNotificationOpened = _onNotificationOpened;
    unawaited(FcmTokenService.consumeInitialMessage());
  }

  /// Call after login / preference change so sockets use the fresh JWT.
  Future<void> onAuthChanged() async {
    _initialized = false;
    socketService.disconnect();
    await initialize();
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
        ..addAll((results[0] as List<NotificationModel>)
            .where((n) => n.id.isNotEmpty));
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

  Future<void> _connectSocket({bool force = false}) async {
    await socketService.connect(force: force);

    _socketHandler ??= (dynamic data) {
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
    };

    void attach() {
      final handler = _socketHandler;
      if (handler == null) return;
      socketService.off('notification:new', handler);
      socketService.on('notification:new', handler);
    }

    attach();
    socketService.onConnect(attach);
  }

  void _onForegroundPush(Map<String, dynamic> data) {
    // Refresh inbox when a push arrives while the app is open.
    unawaited(refresh());
    _applyPushNavigationHints(data);
  }

  void _onNotificationOpened(Map<String, dynamic> data) {
    unawaited(refresh());
    _applyPushNavigationHints(data, navigate: true);
  }

  void _applyPushNavigationHints(
    Map<String, dynamic> data, {
    bool navigate = false,
  }) {
    final type = data['type']?.toString() ?? '';
    if (type == 'test_result_synced') {
      final attemptId =
          data['postId']?.toString() ?? data['attemptId']?.toString();
      if (attemptId != null && attemptId.isNotEmpty) {
        pendingAttemptId = attemptId;
        if (navigate) {
          pendingDashboardTab = 4;
          pendingOpenAllTests = true;
        }
        notifyListeners();
      }
      return;
    }
    if (!navigate) return;
    final postId = data['postId']?.toString();
    if (postId != null && postId.isNotEmpty) {
      requestCommunityNavigation(postId: postId);
    }
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

  void requestAllTestsNavigation({String? attemptId}) {
    pendingDashboardTab = 4;
    pendingOpenAllTests = true;
    pendingAttemptId = attemptId;
    notifyListeners();
  }

  void clearPendingNavigation() {
    pendingDashboardTab = null;
    pendingPostId = null;
    pendingOpenAllTests = false;
    pendingAttemptId = null;
  }

  void reset() {
    FcmTokenService.onForegroundMessage = null;
    FcmTokenService.onNotificationOpened = null;
    if (_socketHandler != null) {
      socketService.off('notification:new', _socketHandler);
    }
    _socketHandler = null;
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
