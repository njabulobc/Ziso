import 'package:flutter/material.dart';

class ZisoTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
