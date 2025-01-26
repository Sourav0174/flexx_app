import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Color(0xffF5EFE7), // Base background for neumorphic elements
    primary: Color(0xff3E5879), // Slightly darker for primary accents
    secondary: Color(0xff213555), // Lighter tone for secondary surfaces
    tertiary: Color(0xff213555), // Highlights for raised areas
    inversePrimary: Color(0xffB4B4B8), // Text and icon colors for contrast
  ),
  scaffoldBackgroundColor: Color(0xffF5EFE7), // Overall app background
// Smooth edges
);
