import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/data/models/mock_test_model.dart';

class MockTestCard extends StatelessWidget {
  final MockTest test;

  const MockTestCard({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBadges(),
                    const SizedBox(height: 5),
                    Text(test.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    _buildDetailsRow(),
                  ],
                ),
              ),
              if (test.isLocked) const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            ],
          ),
          if (test.progress != null) _buildProgressBar(),
          const SizedBox(height: 15),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(test.icon, color: AppColors.primary),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        _badge(test.type, const Color(0xFFE3F2FD), AppColors.primary),
        const SizedBox(width: 8),
        _badge(test.difficulty, _getDifficultyBg(test.difficulty), _getDifficultyColor(test.difficulty)),
      ],
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text('${test.duration} min', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 10),
        const Text('•', style: TextStyle(color: Colors.grey)),
        const SizedBox(width: 10),
        Text('${test.questions} questions', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        if (test.band != null) ...[
          const Spacer(),
          const Icon(Icons.bar_chart, size: 14, color: Colors.green),
          Text(test.band!, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last attempt progress', style: TextStyle(color: Colors.grey, fontSize: 11)),
              Text('${test.progress}%', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: test.progress! / 100,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    bool isPremium = test.isLocked;
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isPremium ? Colors.grey.shade100 : AppColors.primary,
          foregroundColor: isPremium ? Colors.grey : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: isPremium ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPremium) const Icon(Icons.workspace_premium, size: 18),
            if (!isPremium) Icon(test.progress != null ? Icons.replay : Icons.play_arrow, size: 18),
            const SizedBox(width: 8),
            Text(
              isPremium ? 'Unlock with Premium' : (test.progress != null ? 'Retake Test' : 'Start Test'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String d) {
    if (d == 'Hard') return Colors.red;
    if (d == 'Medium') return Colors.orange;
    return Colors.green;
  }

  Color _getDifficultyBg(String d) {
    return _getDifficultyColor(d).withOpacity(0.1);
  }
}