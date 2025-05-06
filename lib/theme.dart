import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final base = ThemeData.light(useMaterial3: true);
ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF008080),     // teal
  scaffoldBackgroundColor: const Color(0xFF008080),
  fontFamily: 'Retropix',
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: const TextStyle(fontSize: 32, color: Colors.white),
    displayMedium: const TextStyle(fontSize: 28, color: Colors.white),
    displaySmall: const TextStyle(fontSize: 24, color: Colors.white),
    bodyLarge: const TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: const TextStyle(fontSize: 14, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF008080),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(120, 48),
  ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF008080),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: Color(0xFF008080)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF008080)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF008080)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withOpacity(0.8),
    selectedColor: Colors.white,
    labelStyle: const TextStyle(color: Color(0xFF008080)),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF008080),
    primary: const Color(0xFF008080),
    secondary: Colors.amber,
    background: const Color(0xFF008080),
  ),
); 