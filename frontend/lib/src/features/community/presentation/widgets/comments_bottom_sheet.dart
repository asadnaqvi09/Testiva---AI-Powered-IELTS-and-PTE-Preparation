import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../data/models/comment_model.dart';
import '../../../../../widgets/app_theme.dart';

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
      final body = <String, dynamic>{'content': text};
      if (parentId != null) {
        body['parent_id'] = parentId;
      }
      final response = await ApiService.post('/community/${widget.postId}/comments', body);
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

  int _countComments(List<CommentModel> comments) {
    var count = 0;
    for (final comment in comments) {
      count += 1;
      count += _countComments(comment.replies);
    }
    return count;
  }

  int get _totalCommentsCount => _countComments(_comments);

  void _startReply(CommentModel comment) {
    setState(() {
      _replyToCommentId = comment.id;
      _replyToName = comment.fullName;
    });
  }

  Widget _buildCommentTile(CommentModel comment, {double indent = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: Column(
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
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.content,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppTheme.primaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 42, top: 8, bottom: 8),
                child: Row(
                  children: [
                    Text(comment.timeAgo, style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 11)),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _toggleCommentLike(comment.id),
                      child: Row(
                        children: [
                          Icon(
                            comment.likedByMe ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: comment.likedByMe ? Colors.red : AppTheme.secondaryText(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _startReply(comment),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: AppTheme.secondaryText(context),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...comment.replies.map(
          (reply) => _buildCommentTile(reply, indent: indent + 24),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 18, color: AppTheme.secondaryText(context)),
                const SizedBox(width: 8),
                Text(
                  'COMMENTS • $_totalCommentsCount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryText(context),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: AppTheme.iconColor(context)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.dividerColor(context)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.postTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryText(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _comments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: AppTheme.secondaryText(context)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentTile(_comments[index]);
                        },
                      ),
          ),
          if (_replyToName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.surfaceBg(context),
              child: Row(
                children: [
                  Text(
                    'Replying to @$_replyToName',
                    style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToCommentId = null;
                        _replyToName = null;
                      });
                    },
                    child: Icon(Icons.close, size: 16, color: AppTheme.secondaryText(context)),
                  ),
                ],
              ),
            ),
          Divider(height: 1, color: AppTheme.dividerColor(context)),
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
                    style: TextStyle(color: AppTheme.primaryText(context)),
                    decoration: InputDecoration(
                      hintText: _replyToName != null ? 'Write a reply...' : 'Add a comment...',
                      hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                      filled: true,
                      fillColor: AppTheme.inputFill(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppTheme.borderColor(context)),
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
