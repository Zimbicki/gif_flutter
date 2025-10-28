// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de cores moderna e vibrante
  static const primaryColor = Color(0xFF6366F1); // Indigo vibrante
  static const secondaryColor = Color(0xFFEC4899); // Pink
  static const accentColor = Color(0xFF8B5CF6); // Purple
  
  static const gradientColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    
    // AppBar customizado
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    
    // Cards com sombras suaves
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Input fields modernos
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    // Botões estilizados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: primaryColor,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark blue
    
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: primaryColor,
    ),
  );

  // Gradientes decorativos
  static LinearGradient primaryGradient = const LinearGradient(
    colors: gradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Colors.grey[300]!,
      Colors.grey[100]!,
      Colors.grey[300]!,
    ],
  );

  static LinearGradient darkShimmerGradient = LinearGradient(
    colors: [
      Colors.grey[800]!,
      Colors.grey[700]!,
      Colors.grey[800]!,
    ],
  );
}
