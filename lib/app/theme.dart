import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple,
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurple,
    secondary: Colors.purpleAccent,
    surface: Colors.grey[900]!,
    background: Colors.grey[900]!,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.deepPurple,
    inactiveTrackColor: Colors.deepPurple.shade800,
    thumbColor: Colors.deepPurpleAccent,
    overlayColor: Colors.deepPurple.withAlpha(0x29),
    valueIndicatorColor: Colors.deepPurple,
    activeTickMarkColor: Colors.deepPurpleAccent,
    inactiveTickMarkColor: Colors.deepPurple.shade800,
  ),
);