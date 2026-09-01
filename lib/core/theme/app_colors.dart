import 'package:flutter/material.dart';

/// Centralized color tokens for the YellowSpot Design System.
abstract final class AppColors {
  // Brand Primary & Accent (YellowSpot signature)
  static const Color primary = Color(0xFFFFB300); // Amber 600
  static const Color primaryDark = Color(0xFFFFA000); // Amber 700
  static const Color primaryLight = Color(0xFFFFE082); // Amber 200
  static const Color primaryContainer = Color(0xFFFFF8E1); // Amber 50
  
  static const Color secondary = Color(0xFF0F172A); // Slate 900
  static const Color secondaryLight = Color(0xFF334155); // Slate 700

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successContainer = Color(0xFFD1FAE5); // Emerald 100
  static const Color successDark = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);

  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleContainer = Color(0xFFEDE9FE);

  static const Color teal = Color(0xFF14B8A6);
  static const Color tealContainer = Color(0xFFCCFBF1);

  // Neutral Background & Surface Tokens (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color dividerLight = Color(0xFFF1F5F9); // Slate 100

  // Neutral Background & Surface Tokens (Dark Mode)
  static const Color backgroundDark = Color(0xFF0B0F17); // Deep OLED dark
  static const Color surfaceDark = Color(0xFF151C28); // Slate 800-like
  static const Color surfaceElevatedDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);

  // Typography & Content Colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
}
