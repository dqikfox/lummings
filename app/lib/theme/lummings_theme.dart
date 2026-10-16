import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette — cinematic nest night + Heartlight accents.
class LummingsColors {
  static const starYellow = Color(0xFFFFC857);
  static const dreamTeal = Color(0xFF7DE2D1);
  static const futurePurple = Color(0xFFB388FF);
  static const warmWhite = Color(0xFFF5F3EE);
  static const softBlack = Color(0xFF12141C);
  static const glowPink = Color(0xFFFF7AB6);
  static const nightDeep = Color(0xFF070A14);
  static const nightMid = Color(0xFF111827);
  static const surface = Color(0xFF161D2F);
  static const surfaceHi = Color(0xFF1E2740);
  static const nestWood = Color(0xFF2A1F18);
  static const heartGlow = Color(0xFFFFD166);
  static const muted = Color(0xFF94A3B8);

  static const questlight = Color(0xFFFF4D6D);
  static const dreamlight = Color(0xFFC77DFF);
  static const traillight = Color(0xFF52B788);
  static const tidelight = Color(0xFF4CC9F0);
  static const sparklight = Color(0xFFFF85A2);

  static const nestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1020),
      Color(0xFF12182C),
      Color(0xFF0A1628),
      Color(0xFF1A0F24),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  /// Soft vignette overlay for hero areas.
  static const heroGlow = RadialGradient(
    center: Alignment(0, -0.2),
    radius: 1.1,
    colors: [
      Color(0x33FFC857),
      Color(0x14B388FF),
      Color(0x00070A14),
    ],
  );
}

class LummingsTheme {
  static ThemeData get dark {
    final baseDark = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final nunito = GoogleFonts.nunitoTextTheme(baseDark.textTheme).apply(
      bodyColor: LummingsColors.warmWhite,
      displayColor: LummingsColors.warmWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LummingsColors.nightDeep,
      colorScheme: const ColorScheme.dark(
        primary: LummingsColors.starYellow,
        secondary: LummingsColors.dreamTeal,
        tertiary: LummingsColors.futurePurple,
        surface: LummingsColors.surface,
        onPrimary: LummingsColors.softBlack,
        onSurface: LummingsColors.warmWhite,
        onSurfaceVariant: LummingsColors.muted,
      ),
      textTheme: nunito.copyWith(
        headlineLarge: nunito.headlineLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
        headlineMedium: nunito.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
        headlineSmall: nunito.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
        titleLarge: nunito.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: nunito.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: nunito.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: nunito.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: LummingsColors.warmWhite,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF00C1220),
        elevation: 0,
        height: 70,
        indicatorColor: LummingsColors.starYellow.withOpacity(0.2),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.1,
            color: selected ? LummingsColors.starYellow : LummingsColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? LummingsColors.starYellow : LummingsColors.muted,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LummingsColors.starYellow,
          foregroundColor: LummingsColors.softBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LummingsColors.warmWhite,
          side: BorderSide(color: Colors.white.withOpacity(0.16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LummingsColors.surfaceHi,
        selectedColor: LummingsColors.starYellow.withOpacity(0.25),
        labelStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: LummingsColors.warmWhite,
        ),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      cardTheme: CardTheme(
        color: LummingsColors.surface.withOpacity(0.92),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LummingsColors.surfaceHi,
        contentTextStyle: GoogleFonts.nunito(
          color: LummingsColors.warmWhite,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: LummingsColors.starYellow,
        thumbColor: LummingsColors.starYellow,
        inactiveTrackColor: Colors.white12,
        overlayColor: LummingsColors.starYellow.withOpacity(0.12),
        trackHeight: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LummingsColors.surfaceHi,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LummingsColors.starYellow, width: 1.5),
        ),
        labelStyle: const TextStyle(color: LummingsColors.muted),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: LummingsColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 24,
      ),
    );
  }
}
