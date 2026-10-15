import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette — Star Yellow, Dream Teal, Future Purple, Glow Pink, Soft Black.
class LummingsColors {
  static const starYellow = Color(0xFFFFB86C);
  static const dreamTeal = Color(0xFF8BE9FD);
  static const futurePurple = Color(0xFFBD93F9);
  static const warmWhite = Color(0xFFF8F8F2);
  static const softBlack = Color(0xFF1A1F2E);
  static const glowPink = Color(0xFFFF79C6);
  static const nightDeep = Color(0xFF0B1020);
  static const nestWood = Color(0xFF2A1F18);
  static const heartGlow = Color(0xFFFFD166);

  // Per-persona Heartlight accents
  static const questlight = Color(0xFFE63946); // Lumo ruby
  static const dreamlight = Color(0xFFC77DFF); // Lila violet
  static const traillight = Color(0xFF52B788); // Pip emerald
  static const tidelight = Color(0xFF4CC9F0); // Nori moon-blue
  static const sparklight = Color(0xFFFF85A2); // Moki rose
}

class LummingsTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LummingsColors.nightDeep,
      colorScheme: const ColorScheme.dark(
        primary: LummingsColors.starYellow,
        secondary: LummingsColors.dreamTeal,
        tertiary: LummingsColors.futurePurple,
        surface: Color(0xFF151B2D),
        onPrimary: LummingsColors.softBlack,
        onSurface: LummingsColors.warmWhite,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: LummingsColors.warmWhite,
        displayColor: LummingsColors.warmWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF12182A),
        selectedItemColor: LummingsColors.starYellow,
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LummingsColors.starYellow,
          foregroundColor: LummingsColors.softBlack,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2238),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: LummingsColors.starYellow.withOpacity(0.15)),
        ),
      ),
    );
  }
}
