import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /* =====================
   * BRAND / PRIMARY
   * ===================== */

  /// Màu chủ đạo (xanh tím đậm)
  static const Color primary = Color(0xFF2E2A5C);

  /// Accent (dùng cho play button, active icon)
  static const Color accent = Color(0xFF6C63FF);

  /* =====================
   * BACKGROUND
   * ===================== */

  /// Background chính (gradient nền tối)
  static const Color background = Color(0xFF0F102A);

  /// Nền card / section
  static const Color surface = Color(0xFF1B1D3A);

  /// Nền bottom navigation
  static const Color bottomNavBackground = Color(0xFF151638);

  /* =====================
   * TEXT
   * ===================== */

  /// Text chính (Chào buổi tối)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Text phụ (subtitle, time, label)
  static const Color textSecondary = Color(0xFFB3B6E0);

  /// Text mờ hơn
  static const Color textMuted = Color.fromARGB(255, 142, 143, 162);

  /* =====================
   * ICON
   * ===================== */

  /// Icon đang active (BottomNav)
  static const Color iconActive = Color(0xFFFFFFFF);

  /// Icon inactive
  static const Color iconInactive = Color.fromARGB(255, 142, 143, 162);

  /* =====================
   * BUTTON
   * ===================== */

  /// Play button (trắng nổi)
  static const Color playButtonBackground = Color(0xFFFFFFFF);
  static const Color playButtonIcon = Color(0xFF2E2A5C);

  /* =====================
   * CARD / LIST ITEM
   * ===================== */

  /// Card đang phát / mới
  static const Color cardHighlight = Color(0xFF2A2C55);

  /// Divider mờ
  static const Color divider = Color(0xFF2F3166);

  /* =====================
   * STATUS
   * ===================== */

  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
}
