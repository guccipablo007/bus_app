import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _green = Color(0xFF087F5B);
  static const _ink = Color(0xFF17242B);
  static const _surface = Color(0xFFF4F8F7);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _green,
      brightness: Brightness.light,
      surface: _surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _surface,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: _ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: _ink, height: 1.45),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.78),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
