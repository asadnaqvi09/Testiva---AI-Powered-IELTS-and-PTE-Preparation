import 'package:flutter/material.dart';

class PrepModule {
  final String title;
  final int lessonsCount;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  PrepModule({
    required this.title,
    required this.lessonsCount,
    required this.icon,
    required this.color,
    this.isCompleted = false,
  });
}