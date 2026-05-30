import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../data/models/comment_model.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final String postTitle;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.postTitle,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  final _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.get('/community/${widget.postId}/comments');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List list = body['data'] as List;
          setState(() {
            _comments = list.map((item) => CommentModel.fromJson(item as Map<String, dynamic>)).toList();
          });
        }
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    final parentId = _replyToCommentId;
    setState(() {
      _replyToCommentId = null;
      _replyToName = null;
    });

    try {
      final response = await ApiService.post('/community/${widget.postId}/comments', {
        'content': text,
        'parent_id': parentId,
      });
      if (response.statusCode == 201) {
        _fetchComments();
      }
    } catch (_) {}
  }

  Future<void> _toggleCommentLike(String commentId) async {
    try {
      final response = await ApiService.post('/community/comments/$commentId/like', {});
      if (response.statusCode == 200) {
        _fetchComments();
      }
    } catch (_) {}
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  int get _totalCommentsCount {
    int count = 0;
    for (var c in _comments) {
      count++;
      count += c.replies.length;
    }
    return count;
  }

  Widget _buildCommentTile(CommentModel comment, {bool isReply = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF007BFF),
              backgroundImage: comment.profileImage != null ? NetworkImage(comment.profileImage!) : null,
              child: comment.profileImage == null
                  ? Text(
                      _getInitials(comment.fullName),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(comment.content, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 42, top: 8, bottom: 16),
          child: Row(
            children: [
              Text(comment.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _toggleCommentLike(comment.id),
                child: Row(
                  children: [
                    Icon(
                      comment.likedByMe ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: comment.likedByMe ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likeCount}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!isReply) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _replyToCommentId = comment.id;
                      _replyToName = comment.fullName;
                    });
                  },
                  child: const Text(
                    'Reply',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('COMMENTS • $_totalCommentsCount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.postTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _comments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text('No comments yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCommentTile(comment),
                              if (comment.replies.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Column(
                                    children: comment.replies.map((reply) {
                                      return _buildCommentTile(reply, isReply: true);
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
          ),
          if (_replyToName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Text(
                    'Replying to @$_replyToName',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToCommentId = null;
                        _replyToName = null;
                      });
                    },
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyToName != null ? 'Write a reply...' : 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _postComment,
                  icon: const Icon(Icons.send, color: Color(0xFF007BFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}