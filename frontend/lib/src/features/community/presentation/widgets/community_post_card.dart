import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // FIXED: withOpacity ki jagah withValues use kiya
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, color: Colors.grey),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ahmed Wasay', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'IELTS Speaking • 2h ago',
                    style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title & Content
          const Text(
            'Tips for Speaking Part 2',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep your notes short and use bullet points to cover all prompts...',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          // Action Buttons (Like, Comment)
          Row(
            children: [
              _buildAction(Icons.favorite_border, '24'),
              const SizedBox(width: 20),
              _buildAction(Icons.chat_bubble_outline, '5'),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}