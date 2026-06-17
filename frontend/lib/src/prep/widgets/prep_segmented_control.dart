import 'package:flutter/material.dart';
import '../../../../widgets/app_theme.dart';

class PrepSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int mediaCount;

  const PrepSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.mediaCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              context: context,
              title: 'Lessons',
              icon: Icons.menu_book,
              index: 0,
              isActive: selectedIndex == 0,
            ),
          ),
          Expanded(
            child: _buildSegment(
              context: context,
              title: mediaCount > 0 ? 'Media ($mediaCount)' : 'Media',
              icon: Icons.insert_drive_file_outlined,
              index: 1,
              isActive: selectedIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    final isDark = AppTheme.isDark(context);
    
    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? Colors.blueAccent.withOpacity(0.2) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.blue : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.blue : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
