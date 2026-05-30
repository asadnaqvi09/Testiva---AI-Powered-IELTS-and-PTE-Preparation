import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../data/models/community_post_model.dart';
import 'comments_bottom_sheet.dart';

class CommunityPostCard extends StatefulWidget {
  final CommunityPostModel post;
  final VoidCallback onLikeToggled;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLikeToggled,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  late bool isLiked;
  late int likeCount;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likedByMe;
    likeCount = widget.post.likes;
  }

  @override
  void didUpdateWidget(covariant CommunityPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likedByMe != widget.post.likedByMe ||
        oldWidget.post.likes != widget.post.likes) {
      setState(() {
        isLiked = widget.post.likedByMe;
        likeCount = widget.post.likes;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _toggleLike() async {
    setState(() {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
    });

    try {
      final response = await ApiService.post('/community/toggle-post-like/${widget.post.id}', {});
      if (response.statusCode != 200) {
        _revertLike();
      } else {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          widget.onLikeToggled();
        } else {
          _revertLike();
        }
      }
    } catch (_) {
      _revertLike();
    }
  }

  void _revertLike() {
    setState(() {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
    });
  }

  void _onShare() async {
    final String shareText = '${widget.post.title}\n\n${widget.post.content}\n\nShared from Testiva';
    await Share.share(
      shareText,
      subject: 'Testiva Post',
    );
    try {
      await ApiService.post('/community/share-post/${widget.post.id}', {'platform': 'copy_link'});
    } catch (_) {}
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: widget.post.id, postTitle: widget.post.title),
    ).then((_) => widget.onLikeToggled());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF007BFF),
                backgroundImage: widget.post.authorAvatar != null ? NetworkImage(widget.post.authorAvatar!) : null,
                child: widget.post.authorAvatar == null
                    ? Text(_getInitials(widget.post.authorName), style: const TextStyle(color: Colors.white, fontSize: 12))
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(widget.post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.post.tag,
                  style: const TextStyle(color: Color(0xFF0369A1), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.post.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.content,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          if (widget.post.comments > 0) ...[
            Row(
              children: [
                SizedBox(
                  width: (widget.post.comments > 4 ? 4 : widget.post.comments) * 14.0 + 10,
                  height: 24,
                  child: Stack(
                    children: List.generate(widget.post.comments > 4 ? 4 : widget.post.comments, (index) {
                      return Positioned(
                        left: index * 14.0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.primaries[(index + 5) % Colors.primaries.length],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${widget.post.comments} comments', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                SizedBox(width: 6),
                Text('No comments yet', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _action(
                isLiked ? Icons.favorite : Icons.favorite_border,
                '$likeCount',
                isLiked ? Colors.red : Colors.grey,
                _toggleLike,
              ),
              _action(
                Icons.chat_bubble_outline,
                '${widget.post.comments}',
                Colors.grey,
                _showComments,
              ),
              _action(
                Icons.share_outlined,
                'Share',
                Colors.grey,
                _onShare,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => isBookmarked = !isBookmarked),
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? const Color(0xFF007BFF) : Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}