import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../providers/feedback_provider.dart';
import 'widgets/rating_section.dart';
import 'widgets/category_chips.dart';
import 'widgets/feedback_input.dart';
import 'widgets/ai_suggestion_box.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _currentRating = 0;
  String _selectedCategory = 'Overall Experience';


  String _getRatingLabel(int rating) {
    const labels = ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];
    return (rating > 0 && rating <= 5) ? labels[rating] : '';
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Feedback & Suggestions'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            RatingSection(
              currentRating: _currentRating,
              onRatingChanged: (val) => setState(() => _currentRating = val),
            ),
            const SizedBox(height: 20),


            CategoryChips(
              selectedCategory: _selectedCategory,
              onSelected: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),


            AiSuggestionBox(
              suggestionText: 'The IELTS preparation content is very helpful. I would appreciate more mock tests...',
              onUseSuggestion: () {
                feedbackProvider.feedbackController.text =
                'The IELTS preparation content is very helpful. I would appreciate more mock tests...';
              },
            ),
            const SizedBox(height: 20),


            FeedbackInput(
              controller: feedbackProvider.feedbackController,
              currentRating: _currentRating,
              ratingLabel: _selectedCategory,
            ),
          ],
        ),
      ),
    );
  }
}