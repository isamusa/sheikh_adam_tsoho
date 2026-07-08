import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Define brand colors
  static const Color richTeal = Color(0xFF005C53);
  static const Color darkTeal = Color(0xFF003D37);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF000000); // Midnight Black
  static const Color lightBackground = Color(0xFFF8FAFC);
  
  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(textStyle: base.displayLarge, fontWeight: FontWeight.bold, color: color),
      displayMedium: GoogleFonts.playfairDisplay(textStyle: base.displayMedium, fontWeight: FontWeight.bold, color: color),
      displaySmall: GoogleFonts.playfairDisplay(textStyle: base.displaySmall, fontWeight: FontWeight.bold, color: color),
      headlineLarge: GoogleFonts.playfairDisplay(textStyle: base.headlineLarge, fontWeight: FontWeight.w600, color: color),
      headlineMedium: GoogleFonts.playfairDisplay(textStyle: base.headlineMedium, fontWeight: FontWeight.w600, color: color),
      headlineSmall: GoogleFonts.playfairDisplay(textStyle: base.headlineSmall, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.outfit(textStyle: base.titleLarge, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.outfit(textStyle: base.titleMedium, fontWeight: FontWeight.w500, color: color),
      titleSmall: GoogleFonts.outfit(textStyle: base.titleSmall, fontWeight: FontWeight.w500, color: color),
      bodyLarge: GoogleFonts.outfit(textStyle: base.bodyLarge, color: color),
      bodyMedium: GoogleFonts.outfit(textStyle: base.bodyMedium, color: color),
      bodySmall: GoogleFonts.outfit(textStyle: base.bodySmall, color: color),
      labelLarge: GoogleFonts.outfit(textStyle: base.labelLarge, fontWeight: FontWeight.w500, color: color),
      labelMedium: GoogleFonts.outfit(textStyle: base.labelMedium, color: color),
      labelSmall: GoogleFonts.outfit(textStyle: base.labelSmall, color: color),
    );
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: richTeal,
    colorScheme: const ColorScheme.light(
      primary: richTeal,
      secondary: goldAccent,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: richTeal),
      titleTextStyle: GoogleFonts.playfairDisplay(
          color: richTeal, fontWeight: FontWeight.bold, fontSize: 22),
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme, Colors.black87),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: richTeal,
      unselectedItemColor: Colors.grey,
      elevation: 20,
    ),
    iconTheme: const IconThemeData(color: richTeal),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: richTeal,
    colorScheme: const ColorScheme.dark(
      primary: richTeal,
      secondary: goldAccent,
      surface: Color(0xFF0A0A0A),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: goldAccent),
      titleTextStyle: GoogleFonts.playfairDisplay(
          color: goldAccent, fontWeight: FontWeight.bold, fontSize: 22),
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme, Colors.white),
    cardTheme: CardTheme(
      color: const Color(0xFF0A0A0A),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0A0A0A),
      selectedItemColor: goldAccent,
      unselectedItemColor: Colors.grey,
      elevation: 20,
    ),
    iconTheme: const IconThemeData(color: goldAccent),
  );
}
