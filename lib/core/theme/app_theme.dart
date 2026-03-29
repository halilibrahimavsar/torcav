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

  // ── Glow Tiers ──
  static final Map<GlowTier, List<BoxShadow> Function(Color)> glowTiers = {
    GlowTier.low: (Color color) => [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
    GlowTier.med: (Color color) => [
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
    GlowTier.high: (Color color) => [
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
  //  DARK THEME (only theme — neon UI is dark-only)
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
      textTheme: _textTheme(),
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: _appBarTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      cardTheme: _cardTheme(),
      snackBarTheme: _snackBarTheme(),
      navigationBarTheme: _navigationBarTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassWhiteBorder,
        thickness: 0.5,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.15),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.deepBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
          foregroundColor: AppColors.neonCyan,
          elevation: 0,
          side: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
          ),
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

  // Keep lightTheme returning dark as well — neon is dark-only.
  static ThemeData get lightTheme => darkTheme;

  // ─────────────────────────────────────────────────────────────────
  //  Sub-Themes
  // ─────────────────────────────────────────────────────────────────

  static AppBarTheme _appBarTheme() {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.neonCyan,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        color: AppColors.neonCyan,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 4,
      ),
      iconTheme: IconThemeData(
        color: AppColors.neonCyan.withValues(alpha: 0.9),
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.neonCyan.withValues(alpha: 0.12),
        ),
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: AppColors.darkSurfaceLight,
      contentTextStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
        ),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  static NavigationBarThemeData _navigationBarTheme() {
    return NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      height: 72,
      indicatorColor: AppColors.neonCyan.withValues(alpha: 0.08),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.neonCyan : AppColors.textMuted,
          size: selected ? 28 : 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.orbitron(
          color: selected ? AppColors.neonCyan : AppColors.textMuted,
          fontSize: 10,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          letterSpacing: 1,
        );
      }),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.neonCyan.withValues(alpha: 0.15),
      ),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(
          color: AppColors.neonCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      labelStyle: GoogleFonts.outfit(
        color: AppColors.textSecondary,
      ),
      hintStyle: GoogleFonts.outfit(
        color: AppColors.textMuted,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Text Theme (Modernizing with Orbitron + Outfit)
  // ─────────────────────────────────────────────────────────────────
  static TextTheme _textTheme() {
    return TextTheme(
      headlineLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.orbitron(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.neonCyan,
        letterSpacing: 1.5,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 14,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.orbitron(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.neonCyan,
        letterSpacing: 2,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}

