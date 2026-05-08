import 'package:flutter/material.dart';

class MockTest {
  final String title;
  final String type;
  final String difficulty;
  final int duration;
  final int questions;
  final String? band;
  final int? progress;
  final bool isLocked;
  final IconData icon;

  MockTest({
    required this.title,
    required this.type,
    required this.difficulty,
    required this.duration,
    required this.questions,
    this.band,
    this.progress,
    this.isLocked = false,
    required this.icon,
  });
}