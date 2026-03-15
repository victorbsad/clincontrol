import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Colors.purple;
  static const Color primaryDark = Color(0xFF6A1B9A);
  static const Color background = Color(0xFFF5F5F5);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}