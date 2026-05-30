import 'package:flutter/material.dart';

class GlobalStatsCard extends StatelessWidget {
  final bool isDarkMode;
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const GlobalStatsCard({
    super.key,
    required this.isDarkMode,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(

        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          if (icon != null) Icon(icon, color: iconColor ?? Colors.orange, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black
              )),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}