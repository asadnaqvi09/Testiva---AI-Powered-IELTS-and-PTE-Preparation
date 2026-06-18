import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/custom_drawer.dart';
import '../../../../widgets/app_header.dart';
import '../../../../widgets/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../data/models/community_post_model.dart';
import 'widgets/community_post_card.dart';
import 'widgets/community_filter_chips.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CommunityPostModel> _posts = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';
  int _onlineCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initSocket();
  }

  @override
  void dispose() {
    _detachSocketListeners();
    socketService.removeConnectListener(_attachSocketListeners);
    super.dispose();
  }

  Future<void> _initSocket() async {
    await socketService.connect();
    _attachSocketListeners();
    socketService.onConnect(_attachSocketListeners);
  }

  void _attachSocketListeners() {
    socketService.off('post_created', _handlePostCreated);
    socketService.off('post_like_updated', _handlePostLikeUpdated);
    socketService.off('comment_created', _handleCommentCreated);
    socketService.off('post:removed', _handlePostRemoved);
    socketService.off('online_count', _handleOnlineCount);
    socketService.on('post_created', _handlePostCreated);
    socketService.on('post_like_updated', _handlePostLikeUpdated);
    socketService.on('comment_created', _handleCommentCreated);
    socketService.on('post:removed', _handlePostRemoved);
    socketService.on('online_count', _handleOnlineCount);
  }

  void _detachSocketListeners() {
    socketService.off('post_created', _handlePostCreated);
    socketService.off('post_like_updated', _handlePostLikeUpdated);
    socketService.off('comment_created', _handleCommentCreated);
    socketService.off('post:removed', _handlePostRemoved);
    socketService.off('online_count', _handleOnlineCount);
  }

  bool _matchesFilter(String topicTag) {
    if (_selectedFilter == 'All') return true;
    return _selectedFilter == topicTag;
  }

  void _handlePostCreated(dynamic data) {
    if (data is! Map) return;
    try {
      final post = CommunityPostModel.fromJson(Map<String, dynamic>.from(data));
      if (!_matchesFilter(post.tag)) return;
      if (_posts.any((p) => p.id == post.id)) return;
      if (!mounted) return;
      setState(() {
        _posts = [post, ..._posts];
      });
    } catch (e) {
      debugPrint('[Community] post_created parse error: $e');
    }
  }

  void _handlePostLikeUpdated(dynamic data) {
    if (data is! Map) return;
    final postId = data['postId']?.toString();
    final likeCount = data['likeCount'];
    if (postId == null || likeCount is! int) return;
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    if (!mounted) return;
    setState(() {
      _posts[index] = _posts[index].copyWith(likes: likeCount);
    });
  }

  void _handleCommentCreated(dynamic data) {
    if (data is! Map) return;
    final comment = data['comment'];
    if (comment is! Map) return;
    final postId = comment['post_id']?.toString();
    if (postId == null) return;
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    if (!mounted) return;
    setState(() {
      _posts[index] = _posts[index].copyWith(comments: _posts[index].comments + 1);
    });
  }

  void _handlePostRemoved(dynamic data) {
    if (data is! Map) return;
    final postId = data['postId']?.toString();
    if (postId == null) return;
    if (!mounted) return;
    setState(() {
      _posts.removeWhere((p) => p.id == postId);
    });
  }

  void _handleOnlineCount(dynamic data) {
    if (data is! Map) return;
    final count = data['count'];
    if (count is! int) return;
    if (!mounted) return;
    setState(() {
      _onlineCount = count;
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchPosts(),
      _fetchOnlineUsers(),
    ]);
  }

  Future<void> _fetchOnlineUsers() async {
    try {
      final response = await ApiService.get('/community/meta/online-users');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          setState(() {
            _onlineCount = body['data']['online_count'] as int? ?? 0;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final endpoint = _selectedFilter == 'All'
          ? '/community/get-posts'
          : '/community/get-posts?topic_tag=$_selectedFilter';
      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List list = body['data'] as List;
          setState(() {
            _posts = list.map((item) => CommunityPostModel.fromJson(item as Map<String, dynamic>)).toList();
          });
        }
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  void _showCreatePostSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedTag = 'General';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create Post',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppTheme.iconColor(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: AppTheme.primaryText(context)),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'What is your question or tip?',
                        labelStyle: TextStyle(color: AppTheme.secondaryText(context)),
                        hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                        filled: true,
                        fillColor: AppTheme.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderColor(context)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      style: TextStyle(color: AppTheme.primaryText(context)),
                      decoration: InputDecoration(
                        labelText: 'Content',
                        hintText: 'Provide details about your question or tip...',
                        labelStyle: TextStyle(color: AppTheme.secondaryText(context)),
                        hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                        filled: true,
                        fillColor: AppTheme.inputFill(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderColor(context)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Topic Tag: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedTag,
                          items: ['General', 'IELTS', 'PTE'].map((tag) {
                            return DropdownMenuItem<String>(
                              value: tag,
                              child: Text(tag),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() {
                                selectedTag = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty ||
                              contentController.text.trim().isEmpty) {
                            return;
                          }
                          Navigator.pop(context);
                          await _createPost(
                            titleController.text.trim(),
                            contentController.text.trim(),
                            selectedTag,
                          );
                        },
                        child: const Text(
                          'Post',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
  }

  Future<void> _createPost(String title, String content, String tag) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('/community/create-post', {
        'title': title,
        'content': content,
        'topic_tag': tag,
      });
      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post created successfully!')),
            );
          }
          if (body['data'] is Map) {
            _handlePostCreated(body['data']);
          } else {
            _fetchPosts();
          }
        }
      } else {
        final body = jsonDecode(response.body);
        String errMsg = body['message'] ?? 'Failed to create post';
        if (body['errors'] != null && body['errors'] is List) {
          errMsg = (body['errors'] as List).join(', ');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error: Failed to reach server'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.scaffoldBg(context),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(scaffoldKey: _scaffoldKey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Community',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              '$_onlineCount online',
                              style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Share tips, ask questions, find study partners',
                    style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CommunityFilterChips(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _fetchPosts();
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? Center(
                          child: Text(
                            'No posts found',
                            style: TextStyle(color: AppTheme.secondaryText(context)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _posts.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return CommunityPostCard(
                              key: ValueKey(post.id),
                              post: post,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostSheet,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
