import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,


    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFFF2F4F8),

    textTheme: const TextTheme(
      bodySmall: TextStyle(fontSize: 12),
      bodyMedium: TextStyle(fontSize: 14),
      bodyLarge: TextStyle(fontSize: 16),

      titleSmall: TextStyle(fontSize: 16),
      titleMedium: TextStyle(fontSize: 18),
      titleLarge: TextStyle(fontSize: 22),

      labelLarge: TextStyle(fontSize: 14),
    ),
  );
}