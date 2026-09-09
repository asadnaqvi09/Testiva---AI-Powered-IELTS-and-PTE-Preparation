import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

class CommunityFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const CommunityFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  IconData? _iconFor(String filter) {
    switch (filter) {
      case 'Popular':
        return Icons.trending_up_rounded;
      case 'Recent':
        return Icons.access_time_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Popular', 'Recent', 'IELTS', 'PTE'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter.toUpperCase() == selectedFilter.toUpperCase();
          final icon = _iconFor(filter);
          final fg = isSelected ? Colors.white : AppTheme.secondaryText(context);
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007BFF) : AppTheme.surfaceBg(context),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.borderColor(context),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 15, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      color: fg,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
