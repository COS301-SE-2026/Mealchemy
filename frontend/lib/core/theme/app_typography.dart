//font families, sizes, weights etc. 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Display hero/splash
  static TextStyle display   = GoogleFonts.newsreader(fontSize: 40, fontWeight: FontWeight.w900);
  static TextStyle heading1  = GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w800);
  static TextStyle heading2  = GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w600);

  // Body content
  static TextStyle title     = GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle body      = GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle bodyBold  = GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, height: 1.5);
  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle caption   = GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w400, height: 1.4);

  // UI buttons labels
  static TextStyle button    = GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3);
  static TextStyle label     = GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5);

 // Toast snackbar
  static TextStyle toast         = GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, height: 1.35);
  static TextStyle toastSubtitle = GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3);
}
