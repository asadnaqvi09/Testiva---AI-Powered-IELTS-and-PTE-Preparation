import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  final TextEditingController feedbackController = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // This is a comment: dead hardcoded suggestion — UI uses /ai/feedback-suggestion instead
  // void generateAISuggestion() {
  //   _isLoading = true;
  //   notifyListeners();
  //   String aiText = 'I am really enjoying the IELTS speaking practice modules...';
  //   feedbackController.text = aiText;
  //   _isLoading = false;
  //   notifyListeners();
  // }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }
}
