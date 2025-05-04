import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  static const String _textScaleKey = 'text_scale_factor';
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _screenReaderKey = 'screen_reader_enabled';
  static const String _reduceAnimationsKey = 'reduce_animations';
  static const String _fontFamilyKey = 'font_family';

  final SharedPreferences _prefs;
  
  // Settings
  double _textScaleFactor;
  bool _highContrastMode;
  bool _screenReaderEnabled;
  bool _reduceAnimations;
  String _fontFamily;

  // Getters
  double get textScaleFactor => _textScaleFactor;
  bool get highContrastMode => _highContrastMode;
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get reduceAnimations => _reduceAnimations;
  String get fontFamily => _fontFamily;

  // Constructor
  AccessibilityProvider(this._prefs)
      : _textScaleFactor = _prefs.getDouble(_textScaleKey) ?? 1.0,
        _highContrastMode = _prefs.getBool(_highContrastKey) ?? false,
        _screenReaderEnabled = _prefs.getBool(_screenReaderKey) ?? false,
        _reduceAnimations = _prefs.getBool(_reduceAnimationsKey) ?? false,
        _fontFamily = _prefs.getString(_fontFamilyKey) ?? 'Roboto';

  // Methods to update settings
  Future<void> setTextScaleFactor(double value) async {
    if (value != _textScaleFactor) {
      _textScaleFactor = value;
      await _prefs.setDouble(_textScaleKey, value);
      notifyListeners();
    }
  }

  Future<void> setHighContrastMode(bool value) async {
    if (value != _highContrastMode) {
      _highContrastMode = value;
      await _prefs.setBool(_highContrastKey, value);
      notifyListeners();
    }
  }

  Future<void> setScreenReaderEnabled(bool value) async {
    if (value != _screenReaderEnabled) {
      _screenReaderEnabled = value;
      await _prefs.setBool(_screenReaderKey, value);
      notifyListeners();
    }
  }

  Future<void> setReduceAnimations(bool value) async {
    if (value != _reduceAnimations) {
      _reduceAnimations = value;
      await _prefs.setBool(_reduceAnimationsKey, value);
      notifyListeners();
    }
  }

  Future<void> setFontFamily(String value) async {
    if (value != _fontFamily) {
      _fontFamily = value;
      await _prefs.setString(_fontFamilyKey, value);
      notifyListeners();
    }
  }

  // Theme data
  ThemeData getThemeData(ThemeData baseTheme) {
    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontFamily: _fontFamily,
        fontSizeFactor: _textScaleFactor,
      ),
      colorScheme: _highContrastMode
          ? _getHighContrastColorScheme(baseTheme.colorScheme)
          : baseTheme.colorScheme,
    );
  }

  ColorScheme _getHighContrastColorScheme(ColorScheme base) {
    return base.copyWith(
      // Increase contrast for better visibility
      primary: base.primary.value > 0xFF7F7F7F 
          ? const Color(0xFF000000) 
          : const Color(0xFFFFFFFF),
      onPrimary: base.primary.value > 0xFF7F7F7F 
          ? const Color(0xFFFFFFFF) 
          : const Color(0xFF000000),
      // Add more color adjustments as needed
    );
  }

  // Animation duration based on settings
  Duration getAnimationDuration(Duration defaultDuration) {
    return _reduceAnimations 
        ? const Duration(milliseconds: 0) 
        : defaultDuration;
  }
} 