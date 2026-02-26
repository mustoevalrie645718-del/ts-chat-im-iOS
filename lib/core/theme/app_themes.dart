import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Application theme configuration
class AppThemes {
  AppThemes._();

  /// Light theme
  static ThemeData get lightTheme => ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey.shade50,
        canvasColor: Colors.white,
        appBarTheme: const AppBarTheme(color: Colors.white),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF0089FF),
          unselectedItemColor: Color(0xFF8E9AB0),
        ),
        textSelectionTheme: const TextSelectionThemeData().copyWith(cursorColor: Colors.blue),
        checkboxTheme: const CheckboxThemeData().copyWith(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey;
            }
            if (states.contains(WidgetState.selected)) {
              return Colors.blue;
            }
            return Colors.white;
          }),
          side: BorderSide(color: Colors.grey.shade500, width: 1),
        ),
        dialogTheme: const DialogThemeData().copyWith(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.black),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData()
            .copyWith(color: Colors.white, linearTrackColor: Colors.grey[300], circularTrackColor: Colors.grey[300]),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemBlue,
          barBackgroundColor: Colors.white,
          applyThemeToAll: true,
          textTheme: const CupertinoTextThemeData().copyWith(
            navActionTextStyle: TextStyle(color: CupertinoColors.label, fontSize: 17.sp),
            actionTextStyle: TextStyle(color: CupertinoColors.systemBlue, fontSize: 17.sp),
            textStyle: TextStyle(color: CupertinoColors.label, fontSize: 17.sp),
            navLargeTitleTextStyle: TextStyle(color: CupertinoColors.label, fontSize: 20.sp),
            navTitleTextStyle: TextStyle(color: CupertinoColors.label, fontSize: 17.sp),
            pickerTextStyle: TextStyle(color: CupertinoColors.label, fontSize: 17.sp),
            tabLabelTextStyle: TextStyle(color: CupertinoColors.label, fontSize: 17.sp),
            dateTimePickerTextStyle: TextStyle(color: CupertinoColors.label, fontSize: 17.sp),
          ),
        ),
      );

  /// Dark theme
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        canvasColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(color: Color(0xFF1E1E1E)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF0089FF),
          unselectedItemColor: Color(0xFFB0B0B0),
        ),
        textSelectionTheme: const TextSelectionThemeData().copyWith(cursorColor: Colors.blue),
        checkboxTheme: const CheckboxThemeData().copyWith(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey;
            }
            if (states.contains(WidgetState.selected)) {
              return Colors.blue;
            }

            return const Color(0xFF2C2C2C);
          }),
          side: const BorderSide(color: Color(0xFF404040), width: 1),
        ),
        dialogTheme: const DialogThemeData().copyWith(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData()
            .copyWith(color: Colors.white, linearTrackColor: Colors.grey[800], circularTrackColor: Colors.grey[800]),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemBlue,
          barBackgroundColor: const Color(0xFF1E1E1E),
          applyThemeToAll: true,
          textTheme: const CupertinoTextThemeData().copyWith(
            navActionTextStyle: TextStyle(color: CupertinoColors.white, fontSize: 17.sp),
            actionTextStyle: TextStyle(color: CupertinoColors.systemBlue, fontSize: 17.sp),
            textStyle: TextStyle(color: CupertinoColors.white, fontSize: 17.sp),
            navLargeTitleTextStyle: TextStyle(color: CupertinoColors.white, fontSize: 20.sp),
            navTitleTextStyle: TextStyle(color: CupertinoColors.white, fontSize: 17.sp),
            pickerTextStyle: TextStyle(color: CupertinoColors.white, fontSize: 17.sp),
            tabLabelTextStyle: TextStyle(color: CupertinoColors.white, fontSize: 17.sp),
            dateTimePickerTextStyle: TextStyle(color: CupertinoColors.white, fontSize: 17.sp),
          ),
        ),
      );
}
