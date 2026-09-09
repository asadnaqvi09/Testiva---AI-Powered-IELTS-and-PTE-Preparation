class NotificationSender {
  final String id;
  final String fullName;
  final String? avatarUrl;

  NotificationSender({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Someone',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? postId;
  final String? commentId;
  final NotificationSender? sender;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }

    Map<String, dynamic>? senderMap;
    final rawSender = json['sender'];
    if (rawSender is Map<String, dynamic>) {
      senderMap = rawSender;
    } else if (rawSender is Map) {
      senderMap = Map<String, dynamic>.from(rawSender);
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == true,
      createdAt: createdAt,
      postId: json['post_id']?.toString(),
      commentId: json['comment_id']?.toString(),
      sender: senderMap != null ? NotificationSender.fromJson(senderMap) : null,
    );
  }

  bool get isCommunityRelated =>
      (postId != null && postId!.isNotEmpty && !isTestResultSynced) ||
      type == 'preference_new_post' ||
      type == 'post_like' ||
      type == 'post_comment' ||
      type == 'comment_reply' ||
      type == 'admin_new_post';

  bool get isTestResultSynced => type == 'test_result_synced';

  String? get attemptId => isTestResultSynced ? postId : null;
}
