import 'package:flutter/material.dart';

/// Inter type scale used across Testiva screens (Figma Make default family).
class AppTypography {
  static const String fontFamily = 'Inter';

  static TextStyle display({
    Color color = const Color(0xFF0F172A),
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle title({
    Color color = const Color(0xFF0F172A),
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      height: 24 / 18,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle body({
    Color color = const Color(0xFF64748B),
    FontWeight weight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle label({
    Color color = const Color(0xFF64748B),
    FontWeight weight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle caption({
    Color color = const Color(0xFF94A3B8),
    FontWeight weight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle button({
    Color color = Colors.white,
    FontWeight weight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 22 / 16,
      fontWeight: weight,
      color: color,
    );
  }
}
