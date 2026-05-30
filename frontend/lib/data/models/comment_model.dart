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
      profileImage: json['profile_image'] as String?,
      subscriptionType: json['subscription_type'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      replies: repliesList,
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
