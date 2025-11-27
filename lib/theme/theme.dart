import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final colorScheme = brightness == Brightness.light
      ? ColorScheme.light(
          primary: const Color(0xFF009688),
          secondary: const Color(0xFF7B1FA2),
          surface: Colors.white,
          onSurface: const Color(0xFF1E1E1E),
          onSurfaceVariant: const Color(0xFF6E6E6E),
          surfaceContainerHighest: const Color(0xFFF3F3F3),
          surfaceContainer: const Color(0xFFF8F8F8),
          error: const Color(0xFFE51400),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
          tertiary: const Color(0xFFE65100),
          tertiaryContainer: const Color(0xFF1976D2),
          onTertiaryContainer: Colors.white,
        )
      : ColorScheme.dark(
          primary: const Color(0xFF26A69A),
          secondary: const Color(0xFFCE93D8),
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFD4D4D4),
          onSurfaceVariant: const Color(0xFF858585),
          surfaceContainerHighest: const Color(0xFF2D2D30),
          surfaceContainer: const Color(0xFF252526),
          error: const Color(0xFFF48771),
          onPrimary: const Color(0xFF1E1E1E),
          onSecondary: const Color(0xFF1E1E1E),
          onError: const Color(0xFF1E1E1E),
          tertiary: const Color(0xFFFFB74D),
          tertiaryContainer: const Color(0xFF64B5F6),
          onTertiaryContainer: const Color(0xFF1E1E1E),
        );

  return ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
  );
}
