import 'package:flutter/material.dart';

class PrepModule {
  final String title;
  final int lessonsCount;
  final int pdfCount;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  PrepModule({
    required this.title,
    required this.lessonsCount,
    this.pdfCount = 0,
    required this.icon,
    required this.color,
    this.isCompleted = false,
  });
}