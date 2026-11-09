import 'package:flutter/material.dart';

/// Dynamic colors that respond to the current theme (dark/light).
/// Use via BuildContext extension: context.dc.background, context.dc.textMain etc.
class DynamicColors {
  final Color background;
  final Color surface;
  final Color surfaceHighlight;
  final Color textMain;
  final Color textMuted;
  final Color cardBorder;
  final Color inputFill;
  final Color divider;

  const DynamicColors({
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.textMain,
    required this.textMuted,
    required this.cardBorder,
    required this.inputFill,
    required this.divider,
  });

  // ─── Dark palette ─────────────────────────────────────────────────────────
  static const DynamicColors dark = DynamicColors(
    background: Color(0xFF05050A),
    surface: Color(0xFF10101C),
    surfaceHighlight: Color(0xFF1A1A2E),
    textMain: Color(0xFFFFFFFF),
    textMuted: Color(0xFFA0A0B0),
    cardBorder: Color(0x26FFFFFF), // white 15%
    inputFill: Color(0xFF10101C),
    divider: Color(0x1AFFFFFF), // white 10%
  );

  // ─── Light palette ────────────────────────────────────────────────────────
  static const DynamicColors light = DynamicColors(
    background: Color(0xFFF3F4FB),
    surface: Color(0xFFFFFFFF),
    surfaceHighlight: Color(0xFFEAEBF8),
    textMain: Color(0xFF0D0D1A),
    textMuted: Color(0xFF606070),
    cardBorder: Color(0x1A000000), // black 10%
    inputFill: Color(0xFFEEEEF8),
    divider: Color(0x1A000000), // black 10%
  );
}

/// BuildContext extension for easy access: `context.dc.background`
extension DynamicColorsContext on BuildContext {
  DynamicColors get dc => Theme.of(this).brightness == Brightness.dark
      ? DynamicColors.dark
      : DynamicColors.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
