import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const cyan700 = Color(0xFF0E7490);
  static const cyan600 = Color(0xFF0891B2);
  static const cyan100 = Color(0xFFCFFAFE);
  static const cyan50 = Color(0xFFECFEFF);
  static const green400 = Color(0xFF639922);
  static const green600 = Color(0xFF3B6D11);
  static const green50 = Color(0xFFEAF3DE);
  static const green100 = Color(0xFFC0DD97);
  static const pink400 = Color(0xFFD4537E);
  static const pink200 = Color(0xFFED93B1);
  static const pink50 = Color(0xFFFBEAF0);
  static const amber300 = Color(0xFFEF9F27);
  static const amber100 = Color(0xFFFAC775);
  static const trunk = Color(0xFF8B5E3C);
  static const trunkDark = Color(0xFF5C3D1E);
  static const background = Color(0xFFF8FAF5);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2EBD6);
  static const textPrimary = Color(0xFF1A2B12);
  static const textSecondary = Color(0xFF5A7040);
  static const danger = Color(0xFFB94A48);
}

abstract final class AppDimens {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

abstract final class AppAnimations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 700);
  static const xslow = Duration(milliseconds: 1200);
  static const curve = Curves.easeOutCubic;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green400,
        primary: AppColors.green400,
        secondary: AppColors.pink400,
        surface: AppColors.card,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.md),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.green50,
        labelTextStyle: WidgetStatePropertyAll(textTheme.bodySmall),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green400,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.pill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green600,
          minimumSize: const Size(44, 44),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.pill),
          ),
        ),
      ),
    );
  }
}
