import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  final TextEditingController feedbackController = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void generateAISuggestion() {
    _isLoading = true;
    notifyListeners();



    String aiText = 'I am really enjoying the IELTS speaking practice modules. The AI feedback is very helpful, but I would love to see more mock tests for the writing section.';

    feedbackController.text = aiText;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }
}