import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/user_notifier.dart';
import '../../../../../data/models/community_post_model.dart';
import '../../../../../widgets/app_theme.dart';
import 'comments_bottom_sheet.dart';

class CommunityPostCard extends StatefulWidget {
  final CommunityPostModel post;
  final VoidCallback? onDeleted;
  final ValueChanged<CommunityPostModel>? onUpdated;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  late bool isLiked;
  late int likeCount;
  bool isBookmarked = false;
  bool _expanded = false;
  bool _busy = false;

  static const _avatarPalette = [
    Color(0xFF007BFF),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
  ];

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

  bool get _isOwner {
    final myId = UserNotifier.notifier.value['id']?.toString();
    if (myId == null || myId.isEmpty) return false;
    return myId == widget.post.userId;
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
        if (body['success'] != true) {
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
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.dialogBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete post?',
          style: TextStyle(color: AppTheme.primaryText(context), fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This cannot be undone.',
          style: TextStyle(color: AppTheme.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryText(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _deletePost();
  }

  Future<void> _deletePost() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final response = await ApiService.delete('/community/delete-post/${widget.post.id}');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
        widget.onDeleted?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message']?.toString() ?? 'Failed to delete post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showEditDialog() async {
    final titleController = TextEditingController(text: widget.post.title);
    final contentController = TextEditingController(text: widget.post.content);
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edit post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: AppTheme.primaryText(context)),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                        filled: true,
                        fillColor: AppTheme.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      style: TextStyle(color: AppTheme.primaryText(context)),
                      decoration: InputDecoration(
                        hintText: 'Content',
                        hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                        filled: true,
                        fillColor: AppTheme.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: saving
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                final content = contentController.text.trim();
                                if (title.length < 5 || content.length < 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Title min 5 chars, content min 10'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                setSheetState(() => saving = true);
                                try {
                                  final response = await ApiService.patch(
                                    '/community/update-post/${widget.post.id}',
                                    {'title': title, 'content': content},
                                  );
                                  final body =
                                      jsonDecode(response.body) as Map<String, dynamic>;
                                  if (response.statusCode == 200 && body['success'] == true) {
                                    final moderation = body['moderation'];
                                    final isFlagged = moderation is Map &&
                                        moderation['is_flagged'] == true;
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (!mounted) return;
                                    if (isFlagged) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            moderation['message']?.toString() ??
                                                'Updated post is under review',
                                          ),
                                          backgroundColor: Colors.orange.shade800,
                                        ),
                                      );
                                      widget.onDeleted?.call();
                                    } else {
                                      final data = body['data'];
                                      final updated = data is Map
                                          ? CommunityPostModel.fromJson(
                                              Map<String, dynamic>.from(data),
                                            )
                                          : widget.post.copyWith(
                                              title: title,
                                              content: content,
                                            );
                                      widget.onUpdated?.call(updated);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Post updated')),
                                      );
                                    }
                                  } else if (mounted) {
                                    setSheetState(() => saving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          body['message']?.toString() ?? 'Update failed',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (_) {
                                  setSheetState(() => saving = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Connection error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'share':
        _onShare();
        break;
      case 'edit':
        _showEditDialog();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  Widget _commentPreviewRow() {
    final count = widget.post.comments;
    if (count <= 0) {
      return Text(
        'No comments yet',
        style: TextStyle(
          color: AppTheme.secondaryText(context),
          fontSize: 12,
        ),
      );
    }

    final stackCount = count > 4 ? 4 : count;
    return GestureDetector(
      onTap: _showComments,
      child: Row(
        children: [
          SizedBox(
            width: stackCount * 14.0 + 10,
            height: 24,
            child: Stack(
              children: List.generate(stackCount, (index) {
                final color = _avatarPalette[(index + widget.post.id.hashCode.abs()) % _avatarPalette.length];
                return Positioned(
                  left: index * 14.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.cardBg(context), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: color,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count ${count == 1 ? 'comment' : 'comments'}',
            style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.post.content;
    final isLong = content.length > 140;
    final snippet = (!_expanded && isLong) ? '${content.substring(0, 140).trimRight()}… ' : '$content ';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _avatarColorFor(widget.post.authorName),
                backgroundImage:
                    widget.post.authorAvatar != null ? NetworkImage(widget.post.authorAvatar!) : null,
                child: widget.post.authorAvatar == null
                    ? Text(
                        _getInitials(widget.post.authorName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          widget.post.authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.primaryText(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.tagBg(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.post.tag,
                            style: TextStyle(
                              color: AppTheme.tagText(context),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.post.timeAgo,
                      style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppTheme.secondaryText(context), size: 20),
                color: AppTheme.cardBg(context),
                onSelected: _onMenuSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'share', child: Text('Share')),
                  if (_isOwner) ...[
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.post.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppTheme.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isLong ? () => setState(() => _expanded = !_expanded) : null,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: snippet,
                    style: TextStyle(
                      color: AppTheme.secondaryText(context),
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (isLong && !_expanded)
                    const TextSpan(
                      text: 'Read more',
                      style: TextStyle(
                        color: Color(0xFF007BFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _commentPreviewRow(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppTheme.dividerColor(context), height: 1),
          ),
          Row(
            children: [
              _action(
                isLiked ? Icons.favorite : Icons.favorite_border,
                '$likeCount',
                isLiked ? Colors.red : AppTheme.secondaryText(context),
                _toggleLike,
              ),
              const SizedBox(width: 18),
              _action(
                Icons.chat_bubble_outline,
                '${widget.post.comments}',
                AppTheme.secondaryText(context),
                _showComments,
              ),
              const SizedBox(width: 18),
              _action(
                Icons.share_outlined,
                'Share',
                AppTheme.secondaryText(context),
                _onShare,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => isBookmarked = !isBookmarked),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? const Color(0xFF007BFF) : AppTheme.secondaryText(context),
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
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color == Colors.red ? color : AppTheme.secondaryText(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
