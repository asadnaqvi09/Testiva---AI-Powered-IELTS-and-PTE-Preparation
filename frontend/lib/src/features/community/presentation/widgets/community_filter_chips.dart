import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class CommunityFilterChips extends StatelessWidget {
  const CommunityFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'IELTS', 'PTE', 'Recent', 'Popular'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isSelected = filter == 'All';
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {},
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}