class CommunityPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String tag;
  final String title;
  final String content;
  final int likes;
  final int comments;
  final bool likedByMe;
  final DateTime createdAt;

  CommunityPostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.tag,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.likedByMe,
    required this.createdAt,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorName: json['full_name'] as String,
      authorAvatar: json['avatar_url'] as String?,
      tag: json['topic_tag'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      likes: json['like_count'] as int? ?? 0,
      comments: json['comment_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}