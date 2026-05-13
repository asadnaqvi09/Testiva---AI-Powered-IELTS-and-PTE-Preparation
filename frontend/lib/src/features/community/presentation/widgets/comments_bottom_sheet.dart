import 'package:flutter/material.dart';

class CommentsBottomSheet extends StatelessWidget {
  const CommentsBottomSheet({super.key});

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
                const Text('COMMENTS • 5', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('How to improve IELTS Speaking from Band 6 to 7?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                _buildCommentTile(
                  name: 'Sara Ahmed',
                  text: 'I had the exact same plateau! What helped most was watching English YouTube channels...',
                  time: '1h ago', likes: '5', initial: 'SA', color: Colors.purple,
                  hasReplies: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: _buildCommentTile(
                    name: 'Ahmed Khan',
                    text: '@Sara Ahmed Thanks! Which YouTube channels specifically for IELTS vocab do you recommend?',
                    time: '58m ago', likes: '2', initial: 'AK', color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile({required String name, required String text, required String time, required String likes, required String initial, required Color color, bool hasReplies = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 14, backgroundColor: color, child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
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
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(width: 16),
              const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(likes, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(width: 16),
              const Text('Reply', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}