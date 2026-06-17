import 'dart:convert';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/data/models/notification_model.dart';

class NotificationService {
  static Future<List<NotificationModel>> fetchNotifications({
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await ApiService.get(
      '/notifications?limit=$limit&offset=$offset',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message']?.toString() ?? 'Failed to load notifications');
    }
    final list = body['notifications'] as List<dynamic>? ?? [];
    return list
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<int> fetchUnreadCount() async {
    final response = await ApiService.get('/notifications/unread-count');
    if (response.statusCode != 200) return 0;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) return 0;
    return body['unreadCount'] as int? ?? 0;
  }

  static Future<int> markAsRead(String id) async {
    final response = await ApiService.patch('/notifications/$id/read');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['unreadCount'] as int? ?? 0;
  }

  static Future<int> markAllAsRead() async {
    final response = await ApiService.patch('/notifications/read-all');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['unreadCount'] as int? ?? 0;
  }

  static Future<int> deleteNotification(String id) async {
    final response = await ApiService.delete('/notifications/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['unreadCount'] as int? ?? 0;
  }
}
