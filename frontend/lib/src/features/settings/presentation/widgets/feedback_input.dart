import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

import 'feedback_success_screen.dart';

class FeedbackInput extends StatelessWidget {
  final TextEditingController controller;
  final int currentRating;
  final String ratingLabel;

  const FeedbackInput({
    super.key,
    required this.controller,
    required this.currentRating,
    required this.ratingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Comments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us about overall experience...',
                  fillColor: const Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackSuccessScreen(
                    rating: currentRating,
                    ratingLabel: ratingLabel,
                  ),
                ),
              );


              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback Submitted!')),
              );
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text(
              'Submit Feedback',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}