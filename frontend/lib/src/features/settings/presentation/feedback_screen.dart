import 'package:flutter/material.dart';
import 'widgets/rating_section.dart';
import 'widgets/category_chips.dart';
import 'widgets/feedback_input.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  String _selectedCategory = "Overall Experience";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Feedback & Suggestions",
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeroCard(),
            const SizedBox(height: 20),
            RatingSection(
              currentRating: _rating,
              onRatingChanged: (val) => setState(() => _rating = val),
            ),
            const SizedBox(height: 20),
            CategoryChips(
              selectedCategory: _selectedCategory,
              onSelected: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),
            const FeedbackInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF007BFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.white, size: 40),
          SizedBox(height: 15),
          Text("Share Your Experience",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Help us improve TestPrep Hub for 50,000+ students",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}