import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2563EB),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF020617),
      secondary: Color(0xFF64748B),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE2E8F0),
      onSecondaryContainer: Color(0xFF020617),

      surface: Color(0xFFF8FAFC),
      onSurface: Color(0xFF020617),

      surfaceContainerHighest: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF475569),
      outline: Color(0xFFCBD5E1),

      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFFF8FAFC),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    textTheme: Typography.material2021().black,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF22D3EE),
      onPrimary: Color(0xFF020617),
      primaryContainer: Color(0xFF083344),
      onPrimaryContainer: Color(0xFFE5E7EB),
      secondary: Color(0xFF94A3B8),
      onSecondary: Color(0xFF020617),
      secondaryContainer: Color(0xFF0F172A),
      onSecondaryContainer: Color(0xFFE5E7EB),

      surface: Color(0xFF020617),
      onSurface: Color(0xFFE5E7EB),
      surfaceContainerHighest: Color(0xFF0F172A),
      onSurfaceVariant: Color(0xFF94A3B8),

      outline: Color(0xFF1E293B),
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: Color(0xFF020617),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Color(0xFF0F172A), // Slightly lighter than background for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    textTheme: Typography.material2021().white,
  );
}


class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;

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
