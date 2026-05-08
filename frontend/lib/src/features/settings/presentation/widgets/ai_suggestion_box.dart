import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

class AiSuggestionBox extends StatelessWidget {
  final String suggestionText;
  final VoidCallback onUseSuggestion;

  const AiSuggestionBox({
    super.key,
    required this.suggestionText,
    required this.onUseSuggestion
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI PRE-FILL SUGGESTION',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"$suggestionText"',
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontStyle: FontStyle.italic
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onUseSuggestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              elevation: 0,
            ),
            child: const Text("Use This Suggestion", style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }
}