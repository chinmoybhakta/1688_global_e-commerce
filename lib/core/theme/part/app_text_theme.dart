import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {

  static TextTheme lightTextTheme = GoogleFonts.interTextTheme(
    ThemeData.light().textTheme,
  ).copyWith(
    headlineLarge: GoogleFonts.ubuntuSans(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.ubuntuSans(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.ubuntuSans(fontSize: 24, fontWeight: FontWeight.w700),
  );

  static TextTheme darkTextTheme = GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  ).copyWith(
    headlineLarge: GoogleFonts.ubuntuSans(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.ubuntuSans(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.ubuntuSans(fontSize: 24, fontWeight: FontWeight.w700),
  );
}
