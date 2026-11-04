import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Existing application colors; extracting them does not change their values.
abstract final class AppColors {
  static const ink = Color(0xFF244065);
  static const primary = Color(0xFF9ECF9A);
  static const accent = Color(0xFF669933);
  static const textMuted = Color(0xFF6E7373);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFB2C1C0);
  static const surfaceMuted = Color(0xFFF8F8F8);
  static const heading = Color(0xFF2A4768);
  static const textSecondary = Color(0xFF6B7280);
  static const pageBackground = Color(0xFFFAFCFA);
  static const surfaceTint = Color(0xFFF7FAF4);
  static const textBody = Color(0xFF3F4B4B);
  static const divider = Color(0xFFE8E8E8);
  static const textSubtle = Color(0xFF648683);
  static const error = Color(0xFFDB0606);
  static const disabled = Color(0xFFE9EBEB);
  static const warning = Color(0xFFEAB308);
  static const textStrong = Color(0xFF303131);
  static const outline = Color(0xFFE2E4E4);
  static const errorSurface = Color(0xFFFDF2F2);
  static const infoSurface = Color(0xFFEDEFFF);
}

abstract final class AppTheme {
  static ThemeData light() =>
      ThemeData(textTheme: GoogleFonts.poppinsTextTheme());
}
