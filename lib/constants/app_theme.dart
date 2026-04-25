import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppConstants.backgroundColor,

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeNormal,
          color: AppConstants.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeMedium,
          color: AppConstants.textSecondary,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppConstants.textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        color: AppConstants.cardColor,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppConstants.fontSizeNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: AppConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: AppConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppConstants.cardColor,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF37353E);
    const darkCard = Color(0xFF44444E);
    const darkAccent = Color(0xFFF97316);
    const darkPrimary = darkAccent;
    const darkTextPrimary = Color(0xFFD3DAD9);
    const darkTextSecondary = Color(0xFFAEB6B5);
    const darkDivider = Color(0xFF595A64);
    const darkSurfaceVariant = Color(0xFF3D3C46);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkAccent,
        surface: darkCard,
        surfaceContainerHighest: darkSurfaceVariant,
        onPrimary: darkBackground,
        onSecondary: darkBackground,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: darkDivider,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme:
          GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeNormal,
          color: darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeMedium,
          color: darkTextSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        actionsIconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary),
      primaryIconTheme: const IconThemeData(color: darkTextPrimary),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        color: darkCard,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        modalBackgroundColor: darkCard,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: AppConstants.fontSizeNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkDivider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        hintStyle: const TextStyle(color: darkTextSecondary),
        labelStyle: const TextStyle(color: darkTextSecondary),
        prefixIconColor: darkTextSecondary,
        suffixIconColor: darkTextPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
      ),
      dividerColor: darkDivider,
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextPrimary.withValues(alpha: 0.85),
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: darkCard,
        textColor: darkTextPrimary,
        iconColor: darkTextSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        disabledColor: darkDivider,
        selectedColor: darkPrimary,
        secondarySelectedColor: darkAccent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: const TextStyle(color: darkTextPrimary),
        secondaryLabelStyle: const TextStyle(color: darkBackground),
        brightness: Brightness.dark,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: darkAccent),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkAccent;
          }
          return darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkAccent.withValues(alpha: 0.35);
          }
          return darkDivider;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkAccent,
        foregroundColor: darkBackground,
        elevation: 4,
      ),
    );
  }
}
