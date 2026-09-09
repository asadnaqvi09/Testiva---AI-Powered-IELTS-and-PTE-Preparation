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
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }

    return CommunityPostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      authorName: json['full_name']?.toString() ?? 'User',
      authorAvatar: json['avatar_url']?.toString(),
      tag: json['topic_tag']?.toString() ?? 'General',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      likes: json['like_count'] as int? ?? 0,
      comments: json['comment_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  CommunityPostModel copyWith({
    String? title,
    String? content,
    int? likes,
    int? comments,
    bool? likedByMe,
  }) {
    return CommunityPostModel(
      id: id,
      userId: userId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      tag: tag,
      title: title ?? this.title,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 35) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return '${(difference.inDays / 365).floor()}y ago';
  }
}