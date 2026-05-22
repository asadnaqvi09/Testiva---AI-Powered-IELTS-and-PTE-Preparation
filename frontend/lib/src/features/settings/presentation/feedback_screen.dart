import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/api_service.dart'; // Core ApiService handler pipeline
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
  bool _isSending = false; // Form dynamic submission state controller

  // 🚀 Live Database Submission Route Executor
  Future<void> _submitFeedback(FeedbackProvider provider) async {
    final String comment = provider.feedbackController.text.trim();

    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating score before submitting!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a brief description about your experience.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // JSON Payload distribution data structure
      final Map<String, dynamic> bodyData = {
        'rating': _currentRating,
        'category': _selectedCategory,
        'comment': comment,
      };

      final response = await ApiService.post('/feedback', bodyData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you! Your feedback has been recorded successfully. 🚀'),
                backgroundColor: Colors.green,
              ),
            );
            // Form state flush operations
            provider.feedbackController.clear();
            setState(() {
              _currentRating = 0;
              _selectedCategory = 'Overall Experience';
            });
          }
          return;
        }
      }

      _showErrorSnackBar('Server rejected submission. Please try again later.');
    } catch (e) {
      debugPrint("Feedback sync exception: ${e.toString()}");
      _showErrorSnackBar('Network error. Failed to sync feedback with server.');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Feedback & Suggestions'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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

                const SizedBox(height: 25),

                // Centralized Submit Execution Button Action Row
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : () => _submitFeedback(feedbackProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: _isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}