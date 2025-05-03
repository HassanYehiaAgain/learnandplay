import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme provider state
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadThemePreference();
  }

  static const String _themePreferenceKey = 'theme_mode';

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themePreferenceKey);
    
    if (savedThemeMode != null) {
      state = savedThemeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newThemeMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newThemeMode;
    
    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, newThemeMode == ThemeMode.light ? 'light' : 'dark');
  }

  // Check if current theme is dark
  bool get isDarkMode => state == ThemeMode.dark;
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
}); 