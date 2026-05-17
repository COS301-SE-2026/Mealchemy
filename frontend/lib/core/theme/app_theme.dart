//ThemeData object gets passed into MaterialApp in main.dart. This is how flutter makes it apply globally
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colours.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.textDark,
        onSecondary: AppColors.textLight,
        onSurface: isDark ? AppColors.textDark : AppColors.textLight,
        onError: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textDark,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      dividerColor: AppColors.divider,
    );
  }
}
