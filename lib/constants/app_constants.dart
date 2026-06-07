import 'package:flutter/material.dart';

/// App-wide constants for colors, sizes, and strings
class AppConstants {
  // App Info
  static const String appName = 'USL Tutor';
  static const String appTagline = 'Learn Sign Language';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF0F766E);
  static const Color secondaryColor = Color(0xFF1D4ED8);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFF44336);

  static const Color backgroundColor = Color(0xFFF7FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF115E59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFF0FDFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Spacing
  static const double paddingSmall = 6.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 18.0;
  static const double paddingXL = 24.0;

  // Border Radius
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 9.0;
  static const double radiusLarge = 12.0;
  static const double radiusXL = 18.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeNormal = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeXXL = 32.0;

  // Icon Sizes
  static const double iconSizeSmall = 14.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 26.0;
  static const double iconSizeXL = 40.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Strings
  static const String welcomeMessage = 'Welcome back';
  static const String dailyChallenge = 'Daily Challenge';
  static const String continueButton = 'Continue';
  static const String startButton = 'Start';
  static const String nextButton = 'Next';
  static const String skipButton = 'Skip';
  static const String getStartedButton = 'Get Started';

  // Categories
  static const List<String> categories = [
    'Alphabets',
    'Numbers',
    'Greetings',
    'Family',
    'Food',
    'Common Phrases',
    'Colors',
    'Actions',
  ];

  // Difficulty Levels
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';

  // Status Messages
  static const String loadingMessage = 'Loading...';
  static const String errorMessage = 'Something went wrong';
  static const String noDataMessage = 'No data available';
  static const String successMessage = 'Success!';
}
