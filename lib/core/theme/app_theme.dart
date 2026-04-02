import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Glow Tiers ────────────────────────────────────────────────────────
enum GlowTier { low, med, high }

// ── Neon Color Tokens ────────────────────────────────────────────────
/// Centralized color palette for the neon-cyberpunk theme.
class AppColors {
  const AppColors._();

  // ── Primary Neons ──
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonPurple = Color(0xFFBF40FF);
  static const Color neonOrange = Color(0xFFFF6E27);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color neonYellow = Color(0xFFEEFF41);
  static const Color neonBlue = Color(0xFF448AFF);

  // ── Surfaces & Depth ──
  static const Color deepBlack = Color(0xFF020206);
  static const Color darkSurface = Color(0xFF0A0F1E);
  static const Color darkSurfaceLight = Color(0xFF141F33);
  static const Color darkSurfaceLighter = Color(0xFF1C2A45);
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassWhiteBorder = Color(0x1AFFFFFF);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF2F4F7);
  static const Color textSecondary = Color(0xFF98A2B3);
  static const Color textMuted = Color(0xFF667085);

  // ── Light Mode Tokens (Solar-Aero Aesthetic) ──
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFE9F0F6);
  static const Color lightSurfaceTertiary = Color(0xFFD3DFEA);
  static const Color lightGlassBorder = Color(0x3300F5FF); // Hint of Cyan glow
  
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF334155);
  static const Color textMutedLight = Color(0xFF64748B);

  // ── Glow Tiers ──
  static final Map<GlowTier, List<BoxShadow> Function(Color)> glowTiers = {
    GlowTier.low:
        (Color color) => [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
    GlowTier.med:
        (Color color) => [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ],
    GlowTier.high:
        (Color color) => [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
  };

  // ── Legacy Aliases ──
  static const Color darkBg = deepBlack;
  static const Color darkBackground = deepBlack;
  static const Color primary = neonCyan;
}

// ── Spacing Tokens ───────────────────────────────────────────────────
/// Named spacing constants to eliminate magic numbers.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// ── Legacy Compatibility Aliases ─────────────────────────────────────
/// [AppTheme] retains legacy static colour references used across the
/// codebase so existing files keep compiling while we migrate them one
/// by one to [AppColors].
class AppTheme {
  const AppTheme._();

  // — kept for backward compat — prefer AppColors going forward —
  static const Color primaryColor = AppColors.neonCyan;
  static const Color secondaryColor = AppColors.neonPurple;
  static const Color darkBackground = AppColors.deepBlack;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color errorColor = AppColors.neonRed;

  // ─────────────────────────────────────────────────────────────────
  //  DARK THEME
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      primary: AppColors.neonCyan,
      secondary: AppColors.neonPurple,
      tertiary: AppColors.neonGreen,
      surface: AppColors.darkSurface,
      error: AppColors.neonRed,
      onPrimary: AppColors.deepBlack,
      onSecondary: AppColors.deepBlack,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepBlack,
      textTheme: _textTheme(scheme),
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: _appBarTheme(scheme),
      inputDecorationTheme: _inputDecorationTheme(scheme),
      cardTheme: _cardTheme(scheme),
      snackBarTheme: _snackBarTheme(scheme),
      navigationBarTheme: _navigationBarTheme(scheme),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassWhiteBorder,
        thickness: 0.5,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.15)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.deepBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
          foregroundColor: AppColors.neonCyan,
          elevation: 0,
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.neonCyan
              : AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.neonCyan.withValues(alpha: 0.25)
              : AppColors.glassWhite;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonCyan,
        linearTrackColor: AppColors.glassWhite,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.neonCyan,
        labelColor: AppColors.neonCyan,
        unselectedLabelColor: AppColors.textMuted,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: GoogleFonts.orbitron(
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: AppColors.neonCyan,
      secondary: AppColors.neonPurple,
      tertiary: AppColors.neonGreen,
      surface: AppColors.lightSurface,
      error: AppColors.neonRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: Colors.white,
      surfaceContainerHighest: AppColors.lightSurfaceSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _textTheme(scheme),
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: _appBarTheme(scheme),
      inputDecorationTheme: _inputDecorationTheme(scheme),
      cardTheme: _cardTheme(scheme),
      snackBarTheme: _snackBarTheme(scheme),
      navigationBarTheme: _navigationBarTheme(scheme),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGlassBorder,
        thickness: 0.5,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 20,
        shadowColor: AppColors.neonCyan.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.15)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.deepBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.neonCyan
              : AppColors.textMutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.neonCyan.withValues(alpha: 0.3)
              : Colors.black12;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonCyan,
        linearTrackColor: Colors.black12,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.neonCyan,
        labelColor: AppColors.neonCyan,
        unselectedLabelColor: AppColors.textMutedLight,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: GoogleFonts.orbitron(
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Sub-Themes
  // ─────────────────────────────────────────────────────────────────

  static AppBarTheme _appBarTheme(ColorScheme scheme) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: scheme.primary,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        color: scheme.primary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 4,
      ),
      iconTheme: IconThemeData(
        color: scheme.primary.withValues(alpha: 0.9),
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return CardThemeData(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.12)),
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return SnackBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceSecondary,
      contentTextStyle: GoogleFonts.outfit(color: scheme.onSurface, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  static NavigationBarThemeData _navigationBarTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final mutedText = isDark ? AppColors.textMuted : AppColors.textMutedLight;

    return NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      height: 72,
      indicatorColor: scheme.primary.withValues(alpha: 0.08),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? scheme.primary : mutedText,
          size: selected ? 28 : 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.orbitron(
          color: selected ? scheme.primary : mutedText,
          fontSize: 10,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          letterSpacing: 1,
        );
      }),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.15)),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(
          color: scheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      labelStyle: GoogleFonts.outfit(
        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
      ),
      hintStyle: GoogleFonts.outfit(
        color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Text Theme (Modernizing with Orbitron + Outfit)
  // ─────────────────────────────────────────────────────────────────
  static TextTheme _textTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final mutedText = isDark ? AppColors.textMuted : AppColors.textMutedLight;

    return TextTheme(
      headlineLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      headlineSmall: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      titleLarge: GoogleFonts.orbitron(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.primary,
        letterSpacing: 1.5,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 18,
        color: primaryText,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 16,
        color: secondaryText,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(fontSize: 14, color: mutedText),
      labelLarge: GoogleFonts.orbitron(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: scheme.primary,
        letterSpacing: 2,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: mutedText,
        letterSpacing: 1,
      ),
    );
  }
}
