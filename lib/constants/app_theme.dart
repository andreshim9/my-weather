import 'package:flutter/material.dart';

class AppColors {
  // 기본/다크 테마 색상 (호환성 유지)
  static const Color background = Color(0xFF0B132B);
  static const Color surface = Color(0xFF1C2541);
  static const Color surfaceLight = Color(0xFF3A506B);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);

  // 다크 테마 색상
  static const Color darkBackground = Color(0xFF0B132B);
  static const Color darkSurface = Color(0xFF1C2541);
  static const Color darkSurfaceLight = Color(0xFF3A506B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // 화이트(라이트) 테마 색상
  static const Color lightBackground = Color(0xFFF1F5F9); // 깨끗한 소프트 라이트 그레이
  static const Color lightSurface = Color(0xFFFFFFFF);    // 순백색 카드
  static const Color lightSurfaceLight = Color(0xFFE2E8F0); // 서피스 구분선
  static const Color lightTextPrimary = Color(0xFF0F172A);  // 딥 네이비 블랙 (고대비)
  static const Color lightTextSecondary = Color(0xFF334155); // 진한 차콜 그레이
  static const Color lightTextMuted = Color(0xFF64748B);

  // 공통 액센트 컬러
  static const Color primary = Color(0xFF0284C7);   // 선명한 블루
  static const Color primaryLight = Color(0xFF38BDF8);
  static const Color accentSun = Color(0xFFF59E0B); // 앰버 골드
  static const Color accentSunset = Color(0xFFEA580C); // 오렌지 노을
  static const Color accentGreen = Color(0xFF059669); // 그린
  static const Color accentRed = Color(0xFFE11D48); // 레드
}

class AppTheme {
  // 1. 화이트(라이트) 모드 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x18000000), width: 1.2),
        ),
      ),
    );
  }

  // 2. 다크 모드 테마
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x33FFFFFF), width: 1.2),
        ),
      ),
    );
  }
}
