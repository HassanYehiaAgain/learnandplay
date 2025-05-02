import 'package:flutter/material.dart';

// Light color scheme
final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xFF6366F1), // Indigo 500
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFEEF2FF), // Indigo 50
  onPrimaryContainer: const Color(0xFF312E81), // Indigo 900
  secondary: const Color(0xFF10B981), // Emerald 500
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFECFDF5), // Emerald 50
  onSecondaryContainer: const Color(0xFF065F46), // Emerald 900
  tertiary: const Color(0xFFF59E0B), // Amber 500
  onTertiary: Colors.white,
  tertiaryContainer: const Color(0xFFFEF3C7), // Amber 100
  onTertiaryContainer: const Color(0xFF78350F), // Amber 900
  error: const Color(0xFFEF4444), // Red 500
  onError: Colors.white,
  errorContainer: const Color(0xFFFEE2E2), // Red 100
  onErrorContainer: const Color(0xFF7F1D1D), // Red 900
  background: Colors.white,
  onBackground: const Color(0xFF1F2937), // Gray 800
  surface: Colors.white,
  onSurface: const Color(0xFF1F2937), // Gray 800
  surfaceVariant: const Color(0xFFF9FAFB), // Gray 50
  onSurfaceVariant: const Color(0xFF6B7280), // Gray 500
  outline: const Color(0xFFD1D5DB), // Gray 300
  outlineVariant: const Color(0xFFE5E7EB), // Gray 200
  shadow: Colors.black.withOpacity(0.1),
  scrim: Colors.black.withOpacity(0.3),
  inverseSurface: const Color(0xFF1F2937), // Gray 800
  onInverseSurface: Colors.white,
  inversePrimary: const Color(0xFFA5B4FC), // Indigo 300
  surfaceTint: const Color(0xFF6366F1), // Indigo 500
);

// Dark color scheme
final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: const Color(0xFFA5B4FC), // Indigo 300
  onPrimary: const Color(0xFF312E81), // Indigo 900
  primaryContainer: const Color(0xFF4F46E5), // Indigo 600
  onPrimaryContainer: Colors.white,
  secondary: const Color(0xFF34D399), // Emerald 400
  onSecondary: const Color(0xFF065F46), // Emerald 900
  secondaryContainer: const Color(0xFF059669), // Emerald 600
  onSecondaryContainer: Colors.white,
  tertiary: const Color(0xFFFBBF24), // Amber 400
  onTertiary: const Color(0xFF78350F), // Amber 900
  tertiaryContainer: const Color(0xFFD97706), // Amber 600
  onTertiaryContainer: Colors.white,
  error: const Color(0xFFF87171), // Red 400
  onError: const Color(0xFF7F1D1D), // Red 900
  errorContainer: const Color(0xFFDC2626), // Red 600
  onErrorContainer: Colors.white,
  background: const Color(0xFF111827), // Gray 900
  onBackground: Colors.white,
  surface: const Color(0xFF1F2937), // Gray 800
  onSurface: Colors.white,
  surfaceVariant: const Color(0xFF374151), // Gray 700
  onSurfaceVariant: const Color(0xFFD1D5DB), // Gray 300
  outline: const Color(0xFF6B7280), // Gray 500
  outlineVariant: const Color(0xFF4B5563), // Gray 600
  shadow: Colors.black.withOpacity(0.3),
  scrim: Colors.black.withOpacity(0.6),
  inverseSurface: Colors.white,
  onInverseSurface: const Color(0xFF1F2937), // Gray 800
  inversePrimary: const Color(0xFF6366F1), // Indigo 500
  surfaceTint: const Color(0xFFA5B4FC), // Indigo 300
);

// Text styles
final headlineTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: -0.5,
);

final bodyTextStyle = TextStyle(
  fontSize: 16,
  height: 1.5,
  letterSpacing: 0.15,
);

// Button styles
final primaryButtonStyle = ButtonStyle(
  padding: MaterialStateProperty.all<EdgeInsets>(
    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  ),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);

final secondaryButtonStyle = ButtonStyle(
  padding: MaterialStateProperty.all<EdgeInsets>(
    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  ),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(width: 1),
    ),
  ),
);

// Input decoration theme
final inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(width: 1),
  ),
  contentPadding: const EdgeInsets.all(16),
  filled: true,
); 