class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String content;
  final String fullName;
  final String? profileImage;
  final String? subscriptionType;
  final int likeCount;
  final bool likedByMe;
  final DateTime createdAt;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.fullName,
    this.profileImage,
    this.subscriptionType,
    required this.likeCount,
    required this.likedByMe,
    required this.createdAt,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    var repliesList = <CommentModel>[];
    if (json['replies'] != null) {
      repliesList = (json['replies'] as List)
          .map((replyJson) => CommentModel.fromJson(replyJson as Map<String, dynamic>))
          .toList();
    }

    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      fullName: json['full_name'] as String,
      profileImage: (json['profile_image'] ?? json['avatar_url'])?.toString(),
      subscriptionType: json['subscription_type'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      replies: repliesList,
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
