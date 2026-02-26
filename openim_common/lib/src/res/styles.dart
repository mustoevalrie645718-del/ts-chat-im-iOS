import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Styles {
  Styles._();

  // Theme detector function that can be injected by the app
  static bool Function()? _themeDetector;

  // Set custom theme detector (should be called during app initialization)
  static void setThemeDetector(bool Function() detector) {
    _themeDetector = detector;
  }

  // Theme-aware colors
  // Use custom detector if available, otherwise fall back to Get.theme
  static bool get _isDark => _themeDetector?.call() ?? (Get.theme.brightness == Brightness.dark);

  // Primary color - same in both themes
  static Color get c_0089FF => const Color(0xFF0089FF);

  // Text colors - adapt to theme
  static Color get c_0C1C33 => _isDark ? const Color(0xFFE8E8E8) : const Color(0xFF0C1C33); // Primary text
  static Color get c_8E9AB0 => _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF8E9AB0); // Secondary text

  // Background colors - adapt to theme
  static Color get c_FFFFFF => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF); // Card/Container
  static Color get c_F0F2F6 => _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F2F6); // Input background
  static Color get c_F8F9FA => _isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA); // Page background
  static Color get c_F4F5F7 => _isDark ? const Color(0xFF252525) : const Color(0xFFF4F5F7); // Light background
  static Color get c_F2F8FF => _isDark ? const Color(0xFF1A2332) : const Color(0xFFF2F8FF); // Success background
  static Color get c_FFE1DD => _isDark ? const Color(0xFF3D2420) : const Color(0xFFFFE1DD); // Error background

  // Divider colors - adapt to theme
  static Color get c_E8EAEF => _isDark ? const Color(0xFF404040) : const Color(0xFFE8EAEF);

  // Fixed colors - same in both themes
  static Color get c_FF381F => const Color(0xFFFF381F); // Warning/Error
  static Color get c_18E875 => const Color(0xFF18E875); // Online status
  static Color get c_FFB300 => const Color(0xFFFFB300); // Meeting status
  static Color get c_000000 => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000); // Pure black/white
  static Color get c_92B3E0 => const Color(0xFF92B3E0);
  static Color get c_6085B1 => _isDark ? const Color(0xFF8FA5C5) : const Color(0xFF6085B1);
  static Color get c_CCE7FE => _isDark ? const Color(0xFF2A4158) : const Color(0xFFCCE7FE);
  static Color get c_707070 => _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF707070);

  // Opacity variants - now using getters for dynamic theme support
  static Color get c_92B3E0_opacity50 => c_92B3E0.withOpacity(.5);
  static Color get c_E8EAEF_opacity50 => c_E8EAEF.withOpacity(.5);
  static Color get c_FFFFFF_opacity0 => c_FFFFFF.withOpacity(.0);
  static Color get c_FFFFFF_opacity70 => c_FFFFFF.withOpacity(.7);
  static Color get c_FFFFFF_opacity50 => c_FFFFFF.withOpacity(.5);
  static Color get c_0089FF_opacity10 => c_0089FF.withOpacity(.1);
  static Color get c_0089FF_opacity20 => c_0089FF.withOpacity(.2);
  static Color get c_0089FF_opacity50 => c_0089FF.withOpacity(.5);
  static Color get c_FF381F_opacity10 => c_FF381F.withOpacity(.1);
  static Color get c_FF381F_opacity70 => c_FF381F.withOpacity(.7);
  static Color get c_8E9AB0_opacity13 => c_8E9AB0.withOpacity(.13);
  static Color get c_8E9AB0_opacity15 => c_8E9AB0.withOpacity(.15);
  static Color get c_8E9AB0_opacity16 => c_8E9AB0.withOpacity(.16);
  static Color get c_8E9AB0_opacity30 => c_8E9AB0.withOpacity(.3);
  static Color get c_8E9AB0_opacity50 => c_8E9AB0.withOpacity(.5);
  static Color get c_0C1C33_opacity30 => c_0C1C33.withOpacity(.3);
  static Color get c_0C1C33_opacity60 => c_0C1C33.withOpacity(.6);
  static Color get c_0C1C33_opacity85 => c_0C1C33.withOpacity(.85);
  static Color get c_0C1C33_opacity80 => c_0C1C33.withOpacity(.8);
  static Color get c_000000_opacity70 => c_000000.withOpacity(.7);
  static Color get c_000000_opacity15 => c_000000.withOpacity(.15);
  static Color get c_000000_opacity12 => c_000000.withOpacity(.12);
  static Color get c_000000_opacity4 => c_000000.withOpacity(.04);

  /// FFFFFF
  static TextStyle get ts_FFFFFF_21sp => TextStyle(color: c_FFFFFF, fontSize: 21.sp);
  static TextStyle get ts_FFFFFF_20sp_medium =>
      TextStyle(color: c_FFFFFF, fontSize: 20.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_18sp_medium =>
      TextStyle(color: c_FFFFFF, fontSize: 18.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_17sp => TextStyle(color: c_FFFFFF, fontSize: 17.sp);
  static TextStyle get ts_FFFFFF_opacity70_17sp => TextStyle(color: c_FFFFFF_opacity70, fontSize: 17.sp);
  static TextStyle get ts_FFFFFF_17sp_semibold =>
      TextStyle(color: c_FFFFFF, fontSize: 17.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_FFFFFF_17sp_medium =>
      TextStyle(color: c_FFFFFF, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_16sp => TextStyle(color: c_FFFFFF, fontSize: 16.sp);
  static TextStyle get ts_FFFFFF_14sp => TextStyle(color: c_FFFFFF, fontSize: 14.sp);
  static TextStyle get ts_FFFFFF_opacity70_14sp => TextStyle(color: c_FFFFFF_opacity70, fontSize: 14.sp);
  static TextStyle get ts_FFFFFF_14sp_medium =>
      TextStyle(color: c_FFFFFF, fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_FFFFFF_12sp => TextStyle(color: c_FFFFFF, fontSize: 12.sp);
  static TextStyle get ts_FFFFFF_10sp => TextStyle(color: c_FFFFFF, fontSize: 10.sp);

  /// 8E9AB0
  static TextStyle get ts_8E9AB0_10sp_semibold =>
      TextStyle(color: c_8E9AB0, fontSize: 10.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_8E9AB0_10sp => TextStyle(color: c_8E9AB0, fontSize: 10.sp);
  static TextStyle get ts_8E9AB0_12sp => TextStyle(color: c_8E9AB0, fontSize: 12.sp);
  static TextStyle get ts_8E9AB0_13sp => TextStyle(color: c_8E9AB0, fontSize: 13.sp);
  static TextStyle get ts_8E9AB0_14sp => TextStyle(color: c_8E9AB0, fontSize: 14.sp);
  static TextStyle get ts_8E9AB0_15sp => TextStyle(color: c_8E9AB0, fontSize: 15.sp);
  static TextStyle get ts_8E9AB0_16sp => TextStyle(color: c_8E9AB0, fontSize: 16.sp);
  static TextStyle get ts_8E9AB0_17sp => TextStyle(color: c_8E9AB0, fontSize: 17.sp);
  static TextStyle get ts_8E9AB0_opacity50_17sp => TextStyle(color: c_8E9AB0_opacity50, fontSize: 17.sp);

  /// 0C1C33
  static TextStyle get ts_0C1C33_10sp => TextStyle(color: c_0C1C33, fontSize: 10.sp);
  static TextStyle get ts_0C1C33_12sp => TextStyle(color: c_0C1C33, fontSize: 12.sp);
  static TextStyle get ts_0C1C33_12sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 12.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_14sp => TextStyle(color: c_0C1C33, fontSize: 14.sp);
  static TextStyle get ts_0C1C33_14sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_17sp => TextStyle(color: c_0C1C33, fontSize: 17.sp);
  static TextStyle get ts_0C1C33_17sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_15sp_semibold =>
      TextStyle(color: c_0C1C33, fontSize: 15.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0C1C33_17sp_semibold =>
      TextStyle(color: c_0C1C33, fontSize: 17.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0C1C33_20sp => TextStyle(color: c_0C1C33, fontSize: 20.sp);
  static TextStyle get ts_0C1C33_20sp_medium =>
      TextStyle(color: c_0C1C33, fontSize: 20.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0C1C33_20sp_semibold =>
      TextStyle(color: c_0C1C33, fontSize: 20.sp, fontWeight: FontWeight.w600);

  /// 0089FF
  static TextStyle get ts_0089FF_10sp_semibold =>
      TextStyle(color: c_0089FF, fontSize: 10.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0089FF_10sp => TextStyle(color: c_0089FF, fontSize: 10.sp);
  static TextStyle get ts_0089FF_12sp => TextStyle(color: c_0089FF, fontSize: 12.sp);
  static TextStyle get ts_0089FF_14sp => TextStyle(color: c_0089FF, fontSize: 14.sp);
  static TextStyle get ts_0089FF_16sp => TextStyle(color: c_0089FF, fontSize: 16.sp);
  static TextStyle get ts_0089FF_16sp_medium =>
      TextStyle(color: c_0089FF, fontSize: 16.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0089FF_17sp => TextStyle(color: c_0089FF, fontSize: 17.sp);
  static TextStyle get ts_0089FF_17sp_semibold =>
      TextStyle(color: c_0089FF, fontSize: 30.sp, fontWeight: FontWeight.w600);
  static TextStyle get ts_0089FF_17sp_medium =>
      TextStyle(color: c_0089FF, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0089FF_14sp_medium =>
      TextStyle(color: c_0089FF, fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_0089FF_22sp_semibold =>
      TextStyle(color: c_0089FF, fontSize: 22.sp, fontWeight: FontWeight.w600);

  /// FF381F
  static TextStyle get ts_FF381F_17sp => TextStyle(color: c_FF381F, fontSize: 17.sp);
  static TextStyle get ts_FF381F_14sp => TextStyle(color: c_FF381F, fontSize: 14.sp);
  static TextStyle get ts_FF381F_12sp => TextStyle(color: c_FF381F, fontSize: 12.sp);
  static TextStyle get ts_FF381F_10sp => TextStyle(color: c_FF381F, fontSize: 10.sp);

  /// 6085B1
  static TextStyle get ts_6085B1_17sp_medium =>
      TextStyle(color: c_6085B1, fontSize: 17.sp, fontWeight: FontWeight.w500);
  static TextStyle get ts_6085B1_17sp => TextStyle(color: c_6085B1, fontSize: 17.sp);
  static TextStyle get ts_6085B1_12sp => TextStyle(color: c_6085B1, fontSize: 12.sp);
  static TextStyle get ts_6085B1_14sp => TextStyle(color: c_6085B1, fontSize: 14.sp);
}
