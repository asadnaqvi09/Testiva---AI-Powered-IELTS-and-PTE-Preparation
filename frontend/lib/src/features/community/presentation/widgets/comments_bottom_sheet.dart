import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/user_notifier.dart';
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
  final _focusNode = FocusNode();
  String? _replyToCommentId;
  String? _replyToName;

  static const _avatarPalette = [
    Color(0xFF7C3AED),
    Color(0xFF007BFF),
    Color(0xFF059669),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
  ];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
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
    var text = _commentController.text.trim();
    if (text.isEmpty) return;

    final parentId = _replyToCommentId;
    final replyName = _replyToName;
    if (parentId != null && replyName != null && replyName.isNotEmpty) {
      final mention = '@$replyName';
      if (!text.toLowerCase().startsWith(mention.toLowerCase())) {
        text = '$mention $text';
      }
    }

    _commentController.clear();
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
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final moderation = decoded['moderation'];
        final data = decoded['data'];
        final isFlagged = (data is Map && data['is_flagged'] == true) ||
            (moderation is Map && moderation['is_flagged'] == true);

        if (isFlagged && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                moderation is Map
                    ? (moderation['message']?.toString() ??
                        'Your comment is under review and hidden until approved.')
                    : 'Your comment is under review and hidden until approved.',
              ),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          return;
        }
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

  bool _isOwnComment(CommentModel comment) {
    final myId = UserNotifier.notifier.value['id']?.toString();
    if (myId == null || myId.isEmpty) return false;
    return myId == comment.userId;
  }

  Future<void> _editComment(CommentModel comment) async {
    final controller = TextEditingController(text: comment.content);
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.dialogBg(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit comment',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText(context),
                ),
              ),
              content: TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                style: TextStyle(color: AppTheme.primaryText(context)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.inputFill(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.secondaryText(context)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;
                          setDialogState(() => saving = true);
                          try {
                            final response = await ApiService.patch(
                              '/community/comments/${comment.id}',
                              {'content': text},
                            );
                            final body =
                                jsonDecode(response.body) as Map<String, dynamic>;
                            if (response.statusCode == 200 &&
                                body['success'] == true) {
                              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                              final moderation = body['moderation'];
                              if (moderation is Map &&
                                  moderation['is_flagged'] == true &&
                                  mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      moderation['message']?.toString() ??
                                          'Comment under review',
                                    ),
                                    backgroundColor: Colors.orange.shade800,
                                  ),
                                );
                              }
                              _fetchComments();
                            } else {
                              setDialogState(() => saving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      body['message']?.toString() ??
                                          'Failed to update comment',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (_) {
                            setDialogState(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.dialogBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete comment?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryText(context),
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: TextStyle(color: AppTheme.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryText(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final response =
          await ApiService.delete('/community/comments/${comment.id}');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        _fetchComments();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message']?.toString() ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _avatarColorFor(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return _avatarPalette[hash % _avatarPalette.length];
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
    _focusNode.requestFocus();
  }

  Widget _buildMentionText(String content) {
    final mentionRegex = RegExp(r'@[\w.\-]+(?:\s+[\w.\-]+)?');
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in mentionRegex.allMatches(content)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: content.substring(start, match.start),
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppTheme.primaryText(context),
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          fontSize: 13,
          height: 1.4,
          color: Color(0xFF007BFF),
          fontWeight: FontWeight.w600,
        ),
      ));
      start = match.end;
    }
    if (start < content.length) {
      spans.add(TextSpan(
        text: content.substring(start),
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppTheme.primaryText(context),
        ),
      ));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: content,
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppTheme.primaryText(context),
        ),
      ));
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildCommentTile(
    CommentModel comment, {
    bool isReply = false,
    String? parentName,
  }) {
    final avatarRadius = isReply ? 12.0 : 16.0;
    final bubbleColor = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.surfaceBg(context)
        : const Color(0xFFF3F4F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isReply) ...[
                Container(
                  width: 2,
                  margin: const EdgeInsets.only(left: 14, right: 12, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDBFE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: _avatarColorFor(comment.fullName),
                          backgroundImage:
                              comment.profileImage != null ? NetworkImage(comment.profileImage!) : null,
                          child: comment.profileImage == null
                              ? Text(
                                  _getInitials(comment.fullName),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isReply ? 9 : 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.primaryText(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildMentionText(
                                  isReply &&
                                          parentName != null &&
                                          !comment.content.trimLeft().startsWith('@')
                                      ? '@$parentName ${comment.content}'
                                      : comment.content,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: avatarRadius * 2 + 10,
                        top: 8,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            comment.timeAgo,
                            style: TextStyle(
                              color: AppTheme.secondaryText(context),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => _toggleCommentLike(comment.id),
                            child: Row(
                              children: [
                                Icon(
                                  comment.likedByMe ? Icons.favorite : Icons.favorite_border,
                                  size: 14,
                                  color: comment.likedByMe
                                      ? Colors.red
                                      : AppTheme.secondaryText(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${comment.likeCount}',
                                  style: TextStyle(
                                    color: AppTheme.secondaryText(context),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => _startReply(comment),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.reply_rounded,
                                  size: 14,
                                  color: AppTheme.secondaryText(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reply',
                                  style: TextStyle(
                                    color: AppTheme.secondaryText(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isOwnComment(comment)) ...[
                            const Spacer(),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: Icon(
                                Icons.more_horiz,
                                size: 18,
                                color: AppTheme.secondaryText(context),
                              ),
                              color: AppTheme.cardBg(context),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editComment(comment);
                                } else if (value == 'delete') {
                                  _deleteComment(comment);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: isReply ? 28 : 8),
            child: Column(
              children: comment.replies
                  .map(
                    (reply) => _buildCommentTile(
                      reply,
                      isReply: true,
                      parentName: comment.fullName,
                    ),
                  )
                  .toList(),
            ),
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
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'COMMENTS - $_totalCommentsCount',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondaryText(context),
                              fontSize: 12,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.postTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.3,
                          color: AppTheme.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: AppTheme.iconColor(context)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentTile(_comments[index]);
                        },
                      ),
          ),
          if (_replyToName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.surfaceBg(context),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Replying to ',
                            style: TextStyle(
                              color: AppTheme.secondaryText(context),
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '@$_replyToName',
                            style: const TextStyle(
                              color: Color(0xFF007BFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
              top: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    style: TextStyle(color: AppTheme.primaryText(context)),
                    decoration: InputDecoration(
                      hintText: _replyToName != null ? 'Write a reply...' : 'Add a comment...',
                      hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                      filled: true,
                      fillColor: AppTheme.inputFill(context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0xFF007BFF),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _postComment,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
