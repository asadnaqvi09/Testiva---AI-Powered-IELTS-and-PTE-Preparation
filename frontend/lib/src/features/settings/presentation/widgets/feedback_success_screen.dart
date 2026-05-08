import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

class FeedbackSuccessScreen extends StatelessWidget {
  final int rating;
  final String ratingLabel;

  const FeedbackSuccessScreen({
    super.key,
    required this.rating,
    required this.ratingLabel
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Check Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 30),

              const Text(
                'Thank You! 🙏',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              const Text(
                'Your feedback has been submitted successfully. We\'ll use it to improve Testiva!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Rating Stars Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < rating ? Colors.orange : Colors.grey.shade300,
                    size: 35,
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(
                'You rated us: $ratingLabel',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),

              const SizedBox(height: 40),

              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}