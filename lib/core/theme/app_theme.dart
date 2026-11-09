import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Armenia Flag Colors
  static const Color armeniaRed = Color(0xFFD90012);
  static const Color armeniaBlue = Color(0xFF0033A0);
  static const Color armeniaOrange = Color(0xFFF2A800);

  // Brand Accents
  static const Color primary = Color(0xFFFF2E63); // Neon Red-Pink
  static const Color secondary = Color(0xFF00E0FF); // Cyan
  static const Color tertiary = Color(0xFFFFB03A); // Bright Orange
  static const Color neonPurple = Color(0xFFB026FF);

  // Modern Dark Surface Colors (Deep midnight/violet)
  static const Color background = Color(0xFF05050A);
  static const Color surface = Color(0xFF10101C);
  static const Color surfaceHighlight = Color(0xFF1A1A2E);

  // Text
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA0A0B0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFF900020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient techGradient = LinearGradient(
    colors: [primary, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGlassGradient = LinearGradient(
    colors: [
      Color(0x2AFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // ─── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textMain,
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textMuted.withOpacity(0.5), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.tertiary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F4FB),
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: Color(0xFFFFFFFF),
      ),
      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0D0D1A),
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D0D1A)),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEEEF8),
        labelStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF606070), fontSize: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF909090), fontSize: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDDDDEE))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDDDDEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.tertiary, width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  // ─── Glassmorphism Utility ───────────────────────────────────────────────
  static Widget glassCard({
    required Widget child,
    double borderRadius = 24.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    double blur = 20.0,
    Color? borderColor,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: AppColors.subtleGlassGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
