import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'comments_bottom_sheet.dart';

class CommunityPostCard extends StatefulWidget {
  const CommunityPostCard({super.key});

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool isLiked = false;
  bool isBookmarked = false;

  final String postTitle = 'How to improve IELTS Speaking from Band 6 to 7?';
  final String postContent = "I've been stuck at Band 6 for Speaking for 3 attempts. My fluency is okay but examiner said vocabulary is limited...";

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CommentsBottomSheet(),
    );
  }

  void _onShare() async {
    final String shareText = '$postTitle\n\n$postContent\n\nShared from Testiva';

    // Latest share_plus syntax jo har version pe kaam karega
    await Share.share(
      shareText,
      subject: 'IELTS Preparation Tip',
    );
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
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF007BFF),
                child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ahmed Khan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('2h ago', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'IELTS Speaking',
                  style: TextStyle(color: Color(0xFF0369A1), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            postTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            postContent,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
          ),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Read more', style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 65,
                height: 24,
                child: Stack(
                  children: List.generate(4, (index) {
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
              const Text('5 comments', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _action(
                isLiked ? Icons.favorite : Icons.favorite_border,
                '24',
                isLiked ? Colors.red : Colors.grey,
                    () => setState(() => isLiked = !isLiked),
              ),
              _action(
                Icons.chat_bubble_outline,
                '5',
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