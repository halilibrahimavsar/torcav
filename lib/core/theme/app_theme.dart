import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF32E6A1);
  static const Color secondaryColor = Color(0xFF5AD4FF);
  static const Color darkBackground = Color(0xFF070E17);
  static const Color darkSurface = Color(0xFF111D2E);
  static const Color lightBackground = Color(0xFFF3F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFFF5A6A);

  static ThemeData get darkTheme {
    final scheme = const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      error: errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(darkSurface, Colors.white70),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.26)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF132840),
        contentTextStyle: GoogleFonts.rajdhani(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0B1423),
        indicatorColor: primaryColor.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primaryColor : Colors.white70);
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    final scheme = const ColorScheme.light(
      primary: Color(0xFF0D7B55),
      secondary: Color(0xFF1776A2),
      surface: lightSurface,
      error: errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      textTheme: _textTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: const Color(0xFF0D7B55),
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          color: const Color(0xFF0D7B55),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(lightSurface, Colors.black87),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F3D2B),
        contentTextStyle: GoogleFonts.rajdhani(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return TextTheme(
      headlineLarge: GoogleFonts.orbitron(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF102235),
      ),
      headlineMedium: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF102235),
      ),
      titleLarge: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? primaryColor : const Color(0xFF0F7B56),
      ),
      titleMedium: GoogleFonts.rajdhani(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF102235),
      ),
      bodyLarge: GoogleFonts.rajdhani(
        fontSize: 18,
        color: isDark ? Colors.white : const Color(0xFF102235),
      ),
      bodyMedium: GoogleFonts.rajdhani(
        fontSize: 16,
        color: isDark ? Colors.white70 : const Color(0xFF344556),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    Color fillColor,
    Color textColor,
  ) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.8)),
      ),
      labelStyle: GoogleFonts.rajdhani(
        color: textColor.withValues(alpha: 0.75),
      ),
      hintStyle: GoogleFonts.rajdhani(color: textColor.withValues(alpha: 0.5)),
    );
  }
}
