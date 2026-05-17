//define all app colours here, every widget will reference this.
import 'package:flutter/material.dart';

class AppColors {
  //Brand
  static const Color primary     = Color(0xFF5C0018);
  static const Color primaryDark = Color(0xFF570013);
  static const Color accent      = Color(0xFFD4AF37);

  //Background
  static const Color bgLight = Color(0xFFFEF9F1);
  static const Color bgDark  = Color(0xFF1D1C17);

  //Surface (cards, inputs)
  static const Color surfaceLight = Color(0xFFF8F3EB);
  static const Color surfaceDark  = Color(0xFF1A1A1A);

  //Text
  static const Color textLight   = Color(0xFF1D1C17);
  static const Color textDark    = Color(0xFFFFFFFF);
  static const Color textMuted   = Color(0xFF6B7280);

  //Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF97316);
  static const Color divider = Color(0xFFE5E2E1);

  //Gradients
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFF5C0018), Color(0xFFA8003A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient warmBg = LinearGradient(
    colors: [Color(0xFFFEF9F1), Color(0xFFF8F0E3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
