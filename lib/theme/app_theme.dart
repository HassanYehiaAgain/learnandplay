import 'package:flutter/material.dart';

/// App Theme based on logo colors
/// This file defines all color schemes and theme data for the app
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation
  
  // Logo-based colors with exact hex codes
  static const Color teal = Color(0xFF2BA498);      // Primary color
  static const Color yellow = Color(0xFFFFD93D);    // Accent color
  static const Color orange = Color(0xFFF59E0B);    // Highlight color
  static const Color purple = Color(0xFFA855F7);    // Secondary widgets
  static const Color green = Color(0xFF34D399);     // Success states
  static const Color offWhite = Color(0xFFF5F5F5);  // Background tint
  static const Color darkGrey = Color(0xFF333333);  // Text color
  static const Color lightGrey = Color(0xFFE5E7EB); // Dividers, borders
  static const Color mediumGrey = Color(0xFF6B7280); // Secondary text
  
  // Light color scheme based on logo colors
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: teal,
    onPrimary: Colors.white,
    primaryContainer: teal.withOpacity(0.8),
    onPrimaryContainer: Colors.white,
    secondary: purple,
    onSecondary: Colors.white,
    secondaryContainer: purple.withOpacity(0.2),
    onSecondaryContainer: purple.withOpacity(0.8),
    tertiary: yellow,
    onTertiary: darkGrey,
    tertiaryContainer: yellow.withOpacity(0.2),
    onTertiaryContainer: orange,
    error: const Color(0xFFEF4444),
    onError: Colors.white,
    errorContainer: const Color(0xFFFEE2E2),
    onErrorContainer: const Color(0xFF7F1D1D),
    surface: Colors.white,
    onSurface: darkGrey,
    background: offWhite,
    onBackground: darkGrey,
    surfaceContainerHighest: const Color(0xFFF9FAFB),
    onSurfaceVariant: mediumGrey,
    outline: lightGrey,
    outlineVariant: lightGrey.withOpacity(0.5),
    shadow: Colors.black.withOpacity(0.1),
    scrim: Colors.black.withOpacity(0.3),
    inverseSurface: darkGrey,
    onInverseSurface: Colors.white,
    inversePrimary: teal,
    surfaceTint: teal.withOpacity(0.05),
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
    background: const Color(0xFF1E1B29), // Dark theme background (260 30% 10%)
    onBackground: Colors.white,
    surfaceContainerHighest: const Color(0xFF2D2A3A), // Slightly lighter dark purple
    onSurfaceVariant: const Color(0xFFD1D5DB), // Light gray
    outline: const Color(0xFF6B7280), // Medium gray
    outlineVariant: const Color(0xFF4B5563), // Dark gray
    shadow: Colors.black.withOpacity(0.3),
    scrim: Colors.black.withOpacity(0.6),
    inverseSurface: Colors.white,
    onInverseSurface: const Color(0xFF1F2937), // Dark gray
    inversePrimary: const Color(0xFF9B87F5), // Purple
    surfaceTint: const Color(0xFF9B87F5), // Purple
  );

  // Gradients
  static const tealToLightTeal = LinearGradient(
    colors: [teal, Color(0xFF75E5D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const purpleToTeal = LinearGradient(
    colors: [purple, teal],
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

  // Define light theme with all properties from the requirements
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      
      // Background color - using off-white to avoid "white screen of death"
      scaffoldBackgroundColor: offWhite,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: teal,
        elevation: 0,
        iconTheme: IconThemeData(color: teal),
        titleTextStyle: const TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        // Headings - using teal
        displayLarge: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        
        // Titles - using PixelifySans for pixel art game style
        titleLarge: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        
        // Body text - using Inter for readability in sensitive content
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
        ),
        
        // Labels - using PixelifySans for buttons and interactive elements
        labelLarge: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ).apply(
        displayColor: teal,
        bodyColor: darkGrey,
        decorationColor: darkGrey,
      ),
      
      // Elevated Button Theme - teal background with white text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return teal.withOpacity(0.5);
            }
            return teal;
          }),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          elevation: MaterialStateProperty.all<double>(2),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            return Colors.transparent;
          }),
        ),
      ),
      
      // Outlined Button Theme - orange border and text
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(orange),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: orange, width: 2),
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(teal),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
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
      
      // Card Theme - white with subtle shadow
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        labelStyle: TextStyle(color: mediumGrey),
        hintStyle: TextStyle(color: mediumGrey.withOpacity(0.7)),
      ),
      
      // Divider Color - light grey
      dividerColor: lightGrey,
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: mediumGrey,
        size: 24,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return teal;
          }
          return lightGrey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return teal.withOpacity(0.5);
          }
          return lightGrey.withOpacity(0.5);
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return teal;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: mediumGrey),
      ),
      
      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: teal,
        unselectedLabelColor: mediumGrey,
        indicatorColor: teal,
        labelStyle: const TextStyle(
          fontFamily: 'PixelifySans',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'PixelifySans',
        ),
      ),
    );
  }

  // Add a properly constructed dark theme to avoid lerping issues
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      
      // Background color
      scaffoldBackgroundColor: const Color(0xFF1E1B29),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF2D2A3A),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Text theme - must have same structure as light theme to avoid lerping errors
      textTheme: const TextTheme(
        // Headings
        displayLarge: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        
        // Titles
        titleLarge: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        
        // Body text - using Inter for readability in sensitive content
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ).apply(
        displayColor: Colors.white,
        bodyColor: Colors.white,
        decorationColor: Colors.white,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return const Color(0xFF9B87F5).withOpacity(0.5);
            }
            return const Color(0xFF9B87F5);
          }),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          elevation: MaterialStateProperty.all<double>(2),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFFD946EF)),
          side: MaterialStateProperty.all<BorderSide>(
            const BorderSide(color: Color(0xFFD946EF), width: 2),
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF9B87F5)),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
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
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF9B87F5);
          }
          return const Color(0xFF6B7280);
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF9B87F5).withOpacity(0.5);
          }
          return const Color(0xFF6B7280).withOpacity(0.5);
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF9B87F5);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
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
    colors: [Color(0xFF9B87F5), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const blueToGreen = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF86EFAC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleToBlue = LinearGradient(
    colors: [Color(0xFF9B87F5), Color(0xFF0EA5E9)],
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
}

// Text styles - keeping for reference
final headlineTextStyle = TextStyle(
  fontFamily: 'PressStart2P',
  fontWeight: FontWeight.bold,
  height: 1.2,
  letterSpacing: -0.5,
);

final bodyTextStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  height: 1.5,
  letterSpacing: 0.15,
);

// Use PixelifySans for more elements
final buttonTextStyle = TextStyle(
  fontFamily: 'PixelifySans',
  fontWeight: FontWeight.bold,
  letterSpacing: 0.5,
);

final titleTextStyle = TextStyle(
  fontFamily: 'PixelifySans',
  fontWeight: FontWeight.bold,
  height: 1.3,
  letterSpacing: 0.3,
);

final subtitleTextStyle = TextStyle(
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