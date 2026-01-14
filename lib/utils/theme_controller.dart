import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF2563EB),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDBEAFE),
      onPrimaryContainer: const Color(0xFF020617),

      secondary: const Color(0xFF64748B),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE2E8F0),
      onSecondaryContainer: const Color(0xFF020617),

      background: const Color(0xFFF8FAFC),
      onBackground: const Color(0xFF020617),

      surface: Colors.white,
      onSurface: const Color(0xFF020617),
      surfaceVariant: const Color(0xFFF1F5F9),
      onSurfaceVariant: const Color(0xFF475569),

      outline: const Color(0xFFCBD5E1),
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    textTheme: Typography.material2021().black,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF22D3EE),
      onPrimary: const Color(0xFF020617),
      primaryContainer: const Color(0xFF083344),
      onPrimaryContainer: const Color(0xFFE5E7EB),

      secondary: const Color(0xFF94A3B8),
      onSecondary: const Color(0xFF020617),
      secondaryContainer: const Color(0xFF0F172A),
      onSecondaryContainer: const Color(0xFFE5E7EB),

      background: const Color(0xFF020617),
      onBackground: const Color(0xFFE5E7EB),

      surface: const Color(0xFF020617),
      onSurface: const Color(0xFFE5E7EB),
      surfaceVariant: const Color(0xFF0F172A),
      onSurfaceVariant: const Color(0xFF94A3B8),

      outline: const Color(0xFF1E293B),
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF020617),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    textTheme: Typography.material2021().white,
  );
}


class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void setLight() {
    _mode = ThemeMode.light;
    notifyListeners();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
  }

  void setSystem() {
    _mode = ThemeMode.system;
    notifyListeners();
  }
}
