class CommunityPostModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String tag; // e.g., IELTS, PTE, General
  final String timeAgo;
  final String title;
  final String content;
  final int likes;
  final int comments;

  CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.tag,
    required this.timeAgo,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
  });
}