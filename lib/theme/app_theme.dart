import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme based on logo colors
/// This file defines all color schemes and theme data for the app
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation
  
  // Logo-based colors with exact hex codes
  static const Color teal = Color(0xFF2BA498);      // Primary color
  static const Color yellow = Color(0xFFFFDA7B);    // Accent color (slightly muted)
  static const Color orange = Color(0xFFF5B14F);    // Highlight color (slightly muted)
  static const Color purple = Color(0xFFA55FC7);    // Secondary widgets (slightly muted)
  static const Color green = Color(0xFF4DC2A0);     // Success states (slightly muted)
  static const Color offWhite = Color(0xFFF0F2F5);  // Background tint (darker for less brightness)
  static const Color darkGrey = Color(0xFF333333);  // Text color
  static const Color lightGrey = Color(0xFFE0E3E8); // Dividers, borders (slightly darker)
  static const Color mediumGrey = Color(0xFF6B7280); // Secondary text
  
  // Text theme with Google Fonts
  static TextTheme get _textTheme {
    return TextTheme(
      // Headings - using pixel-style font for game aesthetics
      displayLarge: GoogleFonts.pressStart2p(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.pressStart2p(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.pressStart2p(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      
      // Titles - using pixel-style font for headings
      titleLarge: GoogleFonts.vt323(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.vt323(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.vt323(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      
      // Body text - using Inter for readability in sensitive content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
      ),
      
      // Labels - using pixel-style font for buttons and interactive elements
      labelLarge: GoogleFonts.vt323(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: GoogleFonts.vt323(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      labelSmall: GoogleFonts.vt323(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  // Light color scheme based on logo colors, but more eye-friendly
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: teal,
    onPrimary: Colors.white,
    primaryContainer: teal.withOpacity(0.9),
    onPrimaryContainer: Colors.white,
    secondary: teal.withOpacity(0.8),
    onSecondary: Colors.white,
    secondaryContainer: teal.withOpacity(0.15),
    onSecondaryContainer: teal.withOpacity(0.9),
    tertiary: yellow.withOpacity(0.9),
    onTertiary: darkGrey,
    tertiaryContainer: yellow.withOpacity(0.15),
    onTertiaryContainer: orange.withOpacity(0.9),
    error: const Color(0xFFE05252),
    onError: Colors.white,
    errorContainer: const Color(0xFFFCE9E9),
    onErrorContainer: const Color(0xFF7F1D1D),
    surface: const Color(0xFFFAFBFC),
    onSurface: darkGrey,
    surfaceContainerHighest: const Color(0xFFF5F7F9),
    onSurfaceVariant: mediumGrey,
    outline: lightGrey,
    outlineVariant: lightGrey.withOpacity(0.5),
    shadow: Colors.black.withOpacity(0.08),
    scrim: Colors.black.withOpacity(0.3),
    inverseSurface: darkGrey,
    onInverseSurface: Colors.white,
    inversePrimary: teal.withOpacity(0.9),
    surfaceTint: teal.withOpacity(0.03),
  );

  // Dark color scheme - keeping for reference
  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF9B87F5), // Purple
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF7E69AB), // Purple-dark
    onPrimaryContainer: Colors.white,
    secondary: const Color(0xFF0EA5E9), // Blue
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD946EF), // Pink
    onSecondaryContainer: Colors.white,
    tertiary: const Color(0xFFFEF7CD), // Yellow
    onTertiary: const Color(0xFF1F2937), // Dark text for contrast
    tertiaryContainer: const Color(0xFF86EFAC), // Green
    onTertiaryContainer: const Color(0xFF1F2937), // Dark text for contrast
    error: const Color(0xFFF87171), // Light red
    onError: Colors.white,
    errorContainer: const Color(0xFFDC2626), // Red
    onErrorContainer: Colors.white,
    surface: const Color(0xFF1E1B29), // Dark theme background (260 30% 10%)
    onSurface: Colors.white,
    surfaceContainerHighest: const Color(0xFF2D2A3A), // Slightly lighter dark purple
    onSurfaceVariant: const Color(0xFFD1D5DB), // Light gray
    outline: const Color(0xFF6B7280), // Medium gray
    outlineVariant: const Color(0xFF4B5563), // Dark gray
    shadow: Colors.black.withOpacity(0.3),
    scrim: Colors.black.withOpacity(0.6),
    inverseSurface: Colors.white,
    onInverseSurface: const Color(0xFF1F2937), // Dark gray
    inversePrimary: const Color(0xFF9B87F5), // Purple
    surfaceTint: const Color(0xFF9B87F5),
  );

  // Gradients
  static const tealToLightTeal = LinearGradient(
    colors: [teal, Color(0xFF75E5D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const purpleToTeal = LinearGradient(
    colors: [teal, Color(0xFF75E5D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const orangeToYellow = LinearGradient(
    colors: [orange, yellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardBackground = LinearGradient(
    colors: [Colors.white, offWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const warningGradient = LinearGradient(
    colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Get the light theme
  static ThemeData get lightTheme {
    final baseTextTheme = _textTheme;
    final colorScheme = lightColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: offWhite,
      textTheme: baseTextTheme.apply(
        displayColor: colorScheme.onSurface,
        bodyColor: colorScheme.onSurface,
        decorationColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        titleTextStyle: GoogleFonts.vt323(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
      ),
      
      // Elevated Button Theme - teal background with white text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return teal.withOpacity(0.5);
            }
            return teal;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          elevation: WidgetStateProperty.all<double>(2),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            return Colors.transparent;
          }),
        ),
      ),
      
      // Outlined Button Theme - orange border and text
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(orange),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: orange, width: 2),
          ),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(teal),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(
              fontFamily: 'PixelifySans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      
      // Floating Action Button Theme - yellow background with teal icon
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: teal,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Card Theme - adding subtle shadows and rounded corners
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE05252), width: 1),
        ),
      ),
      
      // Divider Color - light grey
      dividerColor: lightGrey,
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: mediumGrey,
        size: 24,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return teal;
          }
          return lightGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return teal.withOpacity(0.5);
          }
          return lightGrey.withOpacity(0.5);
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return teal;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: mediumGrey),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: teal,
        unselectedLabelColor: mediumGrey,
        indicatorColor: teal,
        labelStyle: TextStyle(
          fontFamily: 'PixelifySans',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'PixelifySans',
        ),
      ),
    );
  }

  // Get the dark theme
  static ThemeData get darkTheme {
    final baseTextTheme = _textTheme;
    final colorScheme = darkColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: baseTextTheme.apply(
        displayColor: colorScheme.onSurface,
        bodyColor: colorScheme.onSurface,
        decorationColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        titleTextStyle: GoogleFonts.vt323(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFF9B87F5).withOpacity(0.5);
            }
            return const Color(0xFF9B87F5);
          }),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          elevation: WidgetStateProperty.all<double>(2),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFFD946EF)),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: Color(0xFFD946EF), width: 2),
          ),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFF9B87F5)),
          padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(
              fontFamily: 'PixelifySans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFFEF7CD),
        foregroundColor: const Color(0xFF9B87F5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: const Color(0xFF2D2A3A),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2A3A),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4B5563), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4B5563), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9B87F5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
        ),
        labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
        hintStyle: TextStyle(color: const Color(0xFFD1D5DB).withOpacity(0.7)),
      ),
      
      // Divider Color
      dividerColor: const Color(0xFF4B5563),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFFD1D5DB),
        size: 24,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF9B87F5);
          }
          return const Color(0xFF6B7280);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF9B87F5).withOpacity(0.5);
          }
          return const Color(0xFF6B7280).withOpacity(0.5);
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF9B87F5);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xFF9B87F5),
        unselectedLabelColor: Color(0xFF6B7280),
        indicatorColor: Color(0xFF9B87F5),
        labelStyle: TextStyle(
          fontFamily: 'PixelifySans',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'PixelifySans',
        ),
      ),
    );
  }
}

// Original gradients class - keeping for reference
class AppGradients {
  // Dark theme gradients
  static const purpleToPink = LinearGradient(
    colors: [Color(0xFF2BBEAA), Color(0xFF75E5D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const blueToGreen = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF86EFAC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleToBlue = LinearGradient(
    colors: [Color(0xFF2BBEAA), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const orangeToYellow = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFEF7CD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Light theme gradients
  static const tealToLightTeal = LinearGradient(
    colors: [Color(0xFF2BBEAA), Color(0xFF75E5D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const tealToDeepTeal = LinearGradient(
    colors: [Color(0xFF2BBEAA), Color(0xFF106E80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const lightTealBackground = LinearGradient(
    colors: [Color(0xFFE0F2EF), Color(0xFFF8FDFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const cardBackground = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE0F2EF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const warningGradient = LinearGradient(
    colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Text styles - keeping for reference
final headlineTextStyle = const TextStyle(
  fontFamily: 'PressStart2P',
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: -0.5,
);

final bodyTextStyle = const TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  height: 1.5,
  letterSpacing: 0.15,
);

// Use PixelifySans for more elements
final buttonTextStyle = const TextStyle(
  fontFamily: 'PixelifySans',
  fontWeight: FontWeight.bold,
  letterSpacing: 0.5,
);

final titleTextStyle = const TextStyle(
  fontFamily: 'PixelifySans',
  fontWeight: FontWeight.bold,
  height: 1.3,
  letterSpacing: 0.3,
);

final subtitleTextStyle = const TextStyle(
  fontFamily: 'PixelifySans',
  height: 1.3,
  letterSpacing: 0.2,
);

// Card style with gradient background for better readability
final cardDecoration = BoxDecoration(
  gradient: AppGradients.cardBackground,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

/// USAGE NOTES
/// 
/// To apply this theme to your Flutter app:
/// 
/// 1. Import this file in your main.dart:
///    ```dart
///    import 'path/to/app_theme.dart';
///    ```
/// 
/// 2. Apply the light theme to your MaterialApp:
///    ```dart
///    MaterialApp(
///      theme: AppTheme.lightTheme,
///      // For dark theme support:
///      darkTheme: ThemeData(colorScheme: AppTheme.darkColorScheme, ...),
///      // ...
///    )
///    ```
/// 
/// 3. For custom widgets that need to match the theme:
///    - Game tiles: Use AppTheme.teal, AppTheme.yellow, etc.
///    - Progress indicators: AppTheme.orangeToYellow gradient
///    - Success states: AppTheme.green
///    - Achievement badges: AppTheme.purple
///    - Cards: AppTheme.cardBackground gradient
/// 
/// 4. For custom colors not included in ThemeData:
///    ```dart
///    final color = AppTheme.teal;
///    final gradient = AppTheme.tealToLightTeal;
///    ``` 