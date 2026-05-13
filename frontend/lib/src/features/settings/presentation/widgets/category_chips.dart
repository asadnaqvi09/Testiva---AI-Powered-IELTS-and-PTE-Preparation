import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onSelected;

  const CategoryChips({super.key, required this.selectedCategory, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final categories = ['Overall Experience', 'Mock Tests', 'Prep Content', 'Community', 'UI/Design', 'Performance'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Feedback Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return InkWell(
                onTap: () => onSelected(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007BFF) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(cat,
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontSize: 12)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}