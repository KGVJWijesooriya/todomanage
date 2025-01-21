import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Colors.white,
  colorScheme: const ColorScheme.light(
      primary: Colors.white,
      secondary: Color(0xFF14142B),
      surface: Color(0xFF14142B),
      onSecondary: Colors.white,
      onSurface: Color.fromARGB(255, 241, 241, 241)),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF14142B)),
    bodyMedium: TextStyle(color: Color(0xFF14142B)),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: const Color(0xFF14142B),
    selectionColor: const Color(0xFF14142B).withOpacity(0.2),
    selectionHandleColor: const Color(0xFF73FA92),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF14142B),
  primaryColor: const Color(0xFF14142B),
  colorScheme: const ColorScheme.dark(
      primary: Color(0xFF14142B),
      secondary: Colors.white,
      surface: const Color(0xFF73FA92),
      onSecondary: Color(0xFF24263a),
      onSurface: Color(0xFF24263a)),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: const Color(0xFF73FA92),
    selectionColor: const Color(0xFF73FA92).withOpacity(0.2),
    selectionHandleColor: const Color(0xFF73FA92),
  ),
);
