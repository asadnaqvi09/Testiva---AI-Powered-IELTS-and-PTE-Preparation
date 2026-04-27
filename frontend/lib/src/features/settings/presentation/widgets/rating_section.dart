import 'package:flutter/material.dart';

class RatingSection extends StatelessWidget {
  final int currentRating;
  final Function(int) onRatingChanged;
  final List<String> labels = ["", "Poor", "Fair", "Good", "Very Good", "Excellent"];

  RatingSection({super.key, required this.currentRating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text("Overall Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < currentRating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < currentRating ? Colors.orange : Colors.grey.shade300,
                  size: 40,
                ),
                onPressed: () => onRatingChanged(index + 1),
              );
            }),
          ),
          if (currentRating > 0)
            Text(labels[currentRating],
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}