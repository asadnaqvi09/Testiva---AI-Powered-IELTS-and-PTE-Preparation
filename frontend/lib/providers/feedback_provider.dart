import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  final TextEditingController feedbackController = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void generateAISuggestion() async {
    _isLoading = true;
    notifyListeners();

    // Yahan Future mein AI API call aayegi
    await Future.delayed(const Duration(seconds: 2));

    String aiText = "I am really enjoying the IELTS speaking practice modules. The AI feedback is very helpful, but I would love to see more mock tests for the writing section.";

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