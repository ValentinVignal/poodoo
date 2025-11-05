import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  return ThemeData(
    brightness: brightness,

    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
  );
}
