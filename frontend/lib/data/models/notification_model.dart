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
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Someone',
      avatarUrl: json['avatar_url'] as String?,
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
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      sender: json['sender'] != null
          ? NotificationSender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isCommunityRelated => postId != null && postId!.isNotEmpty && !isTestResultSynced;

  bool get isTestResultSynced => type == 'test_result_synced';

  String? get attemptId => isTestResultSynced ? postId : null;
}
