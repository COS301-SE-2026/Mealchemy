//define all app colours here, every widget will reference this.
import 'package:flutter/material.dart';

class AppColors {
  //Brand
  static const Color primary = Color(0xFF5C0018);
  static const Color primaryDark = Color(0xFF570013);
  static const Color primaryLight = Color(0xFF70172A);
  static const Color primaryGradientLight = Color(0xFFA8003A);
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentMuted = Color(0xFF755B00);
  static const Color accentLight = Color( 0xFFFEF9F1);
  static const Color accentSoft = Color(0xFFC9A84C);
  static const Color tertiaryMuted = Color(0xFF7A5C5C);
  //Background
  static const Color bgLight = Color(0xFFFEF9F1);
  static const Color bgDark = Color(0xFF1D1C17);

  //Surface (cards, inputs)
  static const Color surfaceLight = Color(0xFFF8F3EB);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8F3EB);
  static const Color inputBorder = Color(0xFFE0BFBF);

  //Text
  static const Color textLight = Color.fromARGB(255, 14, 13, 11);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF6B7280);

  //Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF97316);
  static const Color divider = Color(0xFFE5E2E1);

  //Gradients
  static const LinearGradient brand = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryGradientLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandOverlay = LinearGradient(
  colors: [
    Color(0xD95C0018), //primary changed to  85% opacity
    Color(0xD9A8003A), //primaryGradientLight change to 85% opacity
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

static const heroScrim = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x00570013), 
    Color(0xE6570013), 
  ],
  stops: [0.4, 1.0],
);

  static const LinearGradient warmBg = LinearGradient(
    colors: [AppColors.bgLight, AppColors.bgDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
