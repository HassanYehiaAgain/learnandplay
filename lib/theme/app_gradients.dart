import 'package:flutter/material.dart';

/// A utility class that provides pre-defined gradients for consistent UI styling.
class AppGradients {
  /// Purple to pink gradient - used for primary actions and branding
  static const LinearGradient purpleToPink = LinearGradient(
    colors: [Color(0xFF7B5AFF), Color(0xFFFD5EB3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Blue to cyan gradient - used for educational elements
  static const LinearGradient blueToCyan = LinearGradient(
    colors: [Color(0xFF0085FF), Color(0xFF00E0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Green to teal gradient - used for success states
  static const LinearGradient greenToTeal = LinearGradient(
    colors: [Color(0xFF2EC4B6), Color(0xFF00F5D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Orange to yellow gradient - used for achievements and rewards
  static const LinearGradient orangeToYellow = LinearGradient(
    colors: [Color(0xFFFF9E5E), Color(0xFFFFD166)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Red to orange gradient - used for important alerts or warnings
  static const LinearGradient redToOrange = LinearGradient(
    colors: [Color(0xFFFF5D73), Color(0xFFFF9E5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Dark blue to purple gradient - used for premium features
  static const LinearGradient darkBlueToPurple = LinearGradient(
    colors: [Color(0xFF38369A), Color(0xFF7B5AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// A rainbow gradient - used for special occasions and celebrations
  static const LinearGradient rainbow = LinearGradient(
    colors: [
      Color(0xFFFF5D73),
      Color(0xFFFF9E5E),
      Color(0xFFFFD166),
      Color(0xFF2EC4B6),
      Color(0xFF00E0FF),
      Color(0xFF7B5AFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 