import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color sky = Color(0xFF75DDF2);
  static const Color cream = Color(0xFFFFF4D6);
  static const Color purple = Color(0xFF7150B8);
  static const Color green = Color(0xFF80C94A);
  static const Color coral = Color(0xFFF67C72);
  static const Color textNavy = Color(0xFF253447);
  static const Color sunGold = Color(0xFFFFB236);
  static const Color cardWhite = Colors.white;

  // Cartoon Toyland Wood Palette
  static const Color woodDark = Color(0xFF8D5B28);
  static const Color woodMain = Color(0xFFC89658);
  static const Color woodLight = Color(0xFFE5C290);
  static const Color woodTray = Color(0xFFFBF4E4);
  static const Color woodBevel = Color(0xFFA26F36);

  // Cartoon Toyland Candy Palette
  static const Color candyRed = Color(0xFFFF4B4B);
  static const Color candyOrange = Color(0xFFFFA502);
  static const Color candyYellow = Color(0xFFFFD43B);
  static const Color candyGreen = Color(0xFF74B816);
  static const Color candyLime = Color(0xFF94D82D);
  static const Color candyCyan = Color(0xFF22B8CF);
  static const Color candyBlue = Color(0xFF339AF0);
  static const Color candyPink = Color(0xFFFF6B81);
  static const Color candyHotPink = Color(0xFFFF4081);
  static const Color candyPurple = Color(0xFF845EF7);
  static const Color skyLight = Color(0xFFBCE7FD);
  static const Color skyDeep = Color(0xFF5EBEFA);

  static ThemeData lightTheme() {
    final textTheme = GoogleFonts.nunitoTextTheme().apply(
      bodyColor: textNavy,
      displayColor: textNavy,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        primary: purple,
        secondary: green,
        tertiary: coral,
        surface: cardWhite,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: textNavy,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: textNavy,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sunGold,
          foregroundColor: textNavy,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardWhite,
      ),
    );
  }
}
