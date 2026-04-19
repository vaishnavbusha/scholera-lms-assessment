import 'package:flutter/material.dart';

/// Raw color palette for Scholera.
///
/// Direction: crisp modern product surface — cool neutral canvas, saturated
/// role accents, slate-family ink. No warm cream, no editorial softness.
///
/// Consumers should prefer [ColorScheme] tokens where possible. Raw palette
/// entries are used by the theme builder and by primitives that need
/// semantic colors outside the ColorScheme (like status pills).
abstract final class Palette {
  // Canvas. Cool neutral, not warm.
  static const Color paper = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F6);
  static const Color outline = Color(0xFFE6E8EC);
  static const Color outlineStrong = Color(0xFFCBD1DA);

  // Ink — slate family, not black.
  static const Color ink = Color(0xFF0F172A);
  static const Color inkMuted = Color(0xFF475569);
  static const Color inkSubtle = Color(0xFF94A3B8);

  // Role accents — saturated, distinctly different from each other.
  static const Color adminPrimary = Color(0xFF1D4ED8);
  static const Color adminPrimaryHover = Color(0xFF2563EB);
  static const Color adminContainer = Color(0xFFDBE7FE);
  static const Color adminOnContainer = Color(0xFF0B215C);

  static const Color professorPrimary = Color(0xFFD97706);
  static const Color professorPrimaryHover = Color(0xFFEA8F1B);
  static const Color professorContainer = Color(0xFFFEEBCC);
  static const Color professorOnContainer = Color(0xFF663800);

  static const Color studentPrimary = Color(0xFF059669);
  static const Color studentPrimaryHover = Color(0xFF10B981);
  static const Color studentContainer = Color(0xFFD1FAE5);
  static const Color studentOnContainer = Color(0xFF064E3B);

  // Neutral (shared, used on pre-auth screens before role is known).
  static const Color neutralPrimary = Color(0xFF1E293B);
  static const Color neutralPrimaryHover = Color(0xFF334155);
  static const Color neutralContainer = Color(0xFFE2E8F0);
  static const Color neutralOnContainer = Color(0xFF0F172A);

  // Status. Slightly brighter to read well on the cooler canvas.
  static const Color statusNotStarted = Color(0xFF94A3B8);
  static const Color statusInProgress = Color(0xFFF59E0B);
  static const Color statusComplete = Color(0xFF10B981);

  // Signals.
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warn = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF2563EB);
}
