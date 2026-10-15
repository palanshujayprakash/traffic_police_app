import 'package:flutter/material.dart';

/// Institutional theme colors for Traffic Police Assistant
/// Grounded in the Duty Guard design system for high outdoor legibility.
class AppColors {
  AppColors._();

  // Core Brand & Status Colors
  static const Color primary = Color(0xFF0B2A5B); // Deep Navy
  static const Color primaryDark = Color(0xFF071A38); // Pressed state
  static const Color primaryLight = Color(0xFF1E3A8A); // Subtle highlights
  static const Color primaryContainer = Color(0xFF0B2A5B);

  static const Color accent = Color(0xFFF59E0B); // Saffron Amber
  static const Color accentContainer = Color(0xFFFEF3C7);

  static const Color success = Color(0xFF10B981); // Valid Emerald
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color successText = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B); // Amber / Expiring
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningText = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444); // Violation Crimson
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color errorText = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color infoText = Color(0xFF1E40AF);

  // Background & Surfaces
  static const Color canvas = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF); // Card white
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceHighlight = Color(0xFFEAEDFF);

  // Text & Neutrals
  static const Color textPrimary = Color(0xFF0F172A); // Charcoal 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderStrong = Color(0xFFCBD5E1); // Slate 300
  static const Color divider = Color(0xFFF1F5F9);

  // HSRP Number Plate Colors
  static const Color hsrpPlateBg = Color(0xFFFFFFFF);
  static const Color hsrpPlateBorder = Color(0xFF0F172A);
  static const Color hsrpBlueStrip = Color(0xFF0038A8); // India Blue

  // Semantic Aliases for ANPR & Duty Guard Design
  static const Color navyPrimary = primary;
  static const Color saffronCaution = accent;
  static const Color validEmerald = success;
  static const Color crimsonAlert = error;
  static const Color slateNeutral = textSecondary;
  static const Color surfaceLight = canvas;
}
