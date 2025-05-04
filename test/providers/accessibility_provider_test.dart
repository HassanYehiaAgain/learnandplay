import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_play_level_up_flutter/providers/accessibility_provider.dart';

void main() {
  late SharedPreferences prefs;
  late AccessibilityProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    provider = AccessibilityProvider(prefs);
  });

  group('AccessibilityProvider', () {
    test('initializes with default values', () {
      expect(provider.textScaleFactor, 1.0);
      expect(provider.highContrastMode, false);
      expect(provider.screenReaderEnabled, false);
      expect(provider.reduceAnimations, false);
      expect(provider.fontFamily, 'Roboto');
    });

    test('updates text scale factor', () async {
      await provider.setTextScaleFactor(1.5);
      expect(provider.textScaleFactor, 1.5);
      expect(prefs.getDouble('text_scale_factor'), 1.5);
    });

    test('updates high contrast mode', () async {
      await provider.setHighContrastMode(true);
      expect(provider.highContrastMode, true);
      expect(prefs.getBool('high_contrast_mode'), true);
    });

    test('updates screen reader enabled', () async {
      await provider.setScreenReaderEnabled(true);
      expect(provider.screenReaderEnabled, true);
      expect(prefs.getBool('screen_reader_enabled'), true);
    });

    test('updates reduce animations', () async {
      await provider.setReduceAnimations(true);
      expect(provider.reduceAnimations, true);
      expect(prefs.getBool('reduce_animations'), true);
    });

    test('updates font family', () async {
      await provider.setFontFamily('Arial');
      expect(provider.fontFamily, 'Arial');
      expect(prefs.getString('font_family'), 'Arial');
    });

    test('getThemeData applies accessibility settings', () {
      final baseTheme = ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
        ),
      );

      provider.setTextScaleFactor(1.5);
      provider.setHighContrastMode(true);
      provider.setFontFamily('Arial');

      final theme = provider.getThemeData(baseTheme);

      expect(theme.textTheme.bodyLarge?.fontSize, 24); // 16 * 1.5
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Arial');
      
      // High contrast mode should adjust colors
      final primary = theme.colorScheme.primary;
      final onPrimary = theme.colorScheme.onPrimary;
      expect(
        primary == Colors.black || primary == Colors.white, 
        true,
      );
      expect(
        onPrimary == Colors.black || onPrimary == Colors.white,
        true,
      );
      expect(primary != onPrimary, true);
    });

    test('getAnimationDuration returns zero duration when animations reduced',
        () async {
      await provider.setReduceAnimations(true);
      final duration = provider.getAnimationDuration(
        const Duration(milliseconds: 300),
      );
      expect(duration, const Duration(milliseconds: 0));
    });

    test('getAnimationDuration returns normal duration when animations enabled',
        () {
      final duration = provider.getAnimationDuration(
        const Duration(milliseconds: 300),
      );
      expect(duration, const Duration(milliseconds: 300));
    });
  });
} 