import 'package:flutter/material.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class AppTextStyles {
  AppTextStyles._(); // private constructor

  static const _fontFamily = 'Roboto';

  /// ===== HEADINGS =====
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.3,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  /// ===== BODY =====
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.6,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.6,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );

  /// ===== CAPTION =====
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
  );
}
