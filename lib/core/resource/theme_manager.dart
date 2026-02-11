import 'package:ecommece_site_1688/core/resource/style_manager.dart';
import 'package:ecommece_site_1688/core/resource/value_manager.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: false, // set true if using Material 3
    // ===== Main colors =====
    primaryColor: Color(0xFFFBFBFB),
    primaryColorLight: Color(0xFFFBFBFB),
    primaryColorDark: Color(0xFFFBFBFB),
    disabledColor: Color(0xFFBDBDBD),
    splashColor: Color(0XFFFFFFFF),
    scaffoldBackgroundColor: Color(0xFFFBFBFB),
 
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Color(0xFF212121),
      error: Color(0xFFFF0000),
    ),
 
    // ===== Card Theme =====
    cardTheme: CardThemeData(
      color: Color(0xFFFFFFFF),
      shadowColor: Color(0xFFBDBDBD),
      elevation: AppSize.s4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),
    ),
 
    // ===== AppBar Theme =====
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFFFBFBFB),
      elevation: AppSize.s4,
      iconTheme: IconThemeData(color: Color(0xFF212121)),
      titleTextStyle: getSemiLargeStyle() as TextStyle?,
    ),
 
    // ===== Button Theme =====
    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: Color(0xFFBDBDBD),
      buttonColor: Color(0xFFFF4000),
      splashColor: Color(0xFF212121),
    ),
 
    // ===== Elevated Button Theme =====
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF4000),
        foregroundColor: Color(0xFFFFFFFF),
        textStyle: getMediumStyle() as TextStyle?,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p16,
          vertical: AppPadding.p12,
        ),
      ),
    ),
 
    // ===== Cursor & Selection Colors =====
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0xFF212121),
      selectionColor: Color(0xFFFF4000).withValues(alpha: 0.1),
      selectionHandleColor: Color(0xFFFF4000),
    ),
 
    // ===== Input Field Theme =====
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFFFFF),
      hintStyle: getMediumStyle(color: Color(0xFF999999)) as TextStyle?,
      labelStyle: getMediumStyle(color: Color(0xFF212121)) as TextStyle?,
      helperStyle: getMediumStyle(color: Color(0xFF212121)) as TextStyle?,
      errorStyle: getMediumStyle(color: Color(0xFFFF0000)) as TextStyle?,
      contentPadding: const EdgeInsets.all(AppPadding.p12),
 
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
        
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFFF4000),
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFFF0000),
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFFF0000),
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
    ),
 
    // ===== Icon Theme =====
    iconTheme: IconThemeData(
      color: Color(0xFF212121),
      size: AppSize.s24,
    ),
  );
}