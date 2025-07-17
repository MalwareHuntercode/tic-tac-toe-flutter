// lib/theme/cyberpunk_theme.dart

import 'package:flutter/material.dart';

class CyberpunkTheme {
  // Level-based color schemes
  static const List<LevelTheme> levelThemes = [
    // Level 1: Neon Blue
    LevelTheme(
      name: 'Neon Rookie',
      primary: Color(0xFF00D9FF),
      secondary: Color(0xFF0066CC),
      accent: Color(0xFF00FFFF),
      background: Color(0xFF0A0E27),
      surface: Color(0xFF1A1E3A),
      neonGlow: Color(0xFF00D9FF),
    ),
    // Level 2: Cyber Purple
    LevelTheme(
      name: 'Digital Warrior',
      primary: Color(0xFFE94CFF),
      secondary: Color(0xFF9B30FF),
      accent: Color(0xFFFF00FF),
      background: Color(0xFF1A0B2E),
      surface: Color(0xFF2D1B4E),
      neonGlow: Color(0xFFE94CFF),
    ),
    // Level 3: Matrix Green
    LevelTheme(
      name: 'Matrix Master',
      primary: Color(0xFF00FF41),
      secondary: Color(0xFF00CC33),
      accent: Color(0xFF39FF14),
      background: Color(0xFF0D1F0D),
      surface: Color(0xFF1A3A1A),
      neonGlow: Color(0xFF00FF41),
    ),
    // Level 4: Cyber Red
    LevelTheme(
      name: 'System Override',
      primary: Color(0xFFFF073A),
      secondary: Color(0xFFCC0025),
      accent: Color(0xFFFF1744),
      background: Color(0xFF1A0A0E),
      surface: Color(0xFF3A1A1E),
      neonGlow: Color(0xFFFF073A),
    ),
    // Level 5: Golden Elite
    LevelTheme(
      name: 'Cyber Legend',
      primary: Color(0xFFFFD700),
      secondary: Color(0xFFFFA500),
      accent: Color(0xFFFFFF00),
      background: Color(0xFF1A1A0A),
      surface: Color(0xFF3A3A1A),
      neonGlow: Color(0xFFFFD700),
    ),
  ];

  static ThemeData getTheme(int level) {
    final levelIndex = (level - 1).clamp(0, levelThemes.length - 1);
    final theme = levelThemes[levelIndex];

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: theme.background,
      colorScheme: ColorScheme.dark(
        primary: theme.primary,
        secondary: theme.secondary,
        surface: theme.surface,
        background: theme.background,
        error: Colors.red,
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: theme.primary,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: theme.neonGlow.withOpacity(0.8),
              blurRadius: 20,
            ),
          ],
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: theme.primary,
          letterSpacing: 1.5,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: theme.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: theme.primary, width: 2),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.primary,
          side: BorderSide(color: theme.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide:
              BorderSide(color: theme.primary.withOpacity(0.5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: theme.primary),
        hintStyle: TextStyle(color: theme.primary.withOpacity(0.5)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: theme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: theme.primary,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: theme.neonGlow.withOpacity(0.8),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class LevelTheme {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color neonGlow;

  const LevelTheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.neonGlow,
  });
}
