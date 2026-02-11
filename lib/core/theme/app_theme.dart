import 'package:ecommece_site_1688/core/theme/part/app_text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFBFBFB),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF212121),
    ),
    textTheme: AppTextTheme.lightTextTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFFFBFBFB),
    ),
    textTheme: AppTextTheme.darkTextTheme,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212),
      selectedItemColor: Color(0xFFFF4000),
      unselectedItemColor: Color(0xFF999999),
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 24),
      showUnselectedLabels: true,
    ),
  );
}
