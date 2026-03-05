import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color _primaryColor = Color(0xFF7C3AED); // Deep violet
  static const Color _secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color _accentColor = Color(0xFFEC4899); // Pink
  static const Color _backgroundDark = Color(0xFF0A0A0F);
  static const Color _surfaceDark = Color(0xFF12121A);
  static const Color _cardDark = Color(0xFF1A1A2E);
  static const Color _glassSurface = Color(0x1AFFFFFF); // 10% white
  static const Color _glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color _textPrimary = Color(0xFFF8FAFC);
  static const Color _textSecondary = Color(0xFF94A3B8);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _successColor = Color(0xFF10B981);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      background: _backgroundDark,
      surface: _surfaceDark,
      surfaceVariant: _cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: _textPrimary,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      error: _errorColor,
      outline: _glassBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundDark,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      navigationBarTheme: _buildNavigationBarTheme(),
      dividerTheme: const DividerThemeData(color: _glassBorder, thickness: 1),
      iconTheme: const IconThemeData(color: _textSecondary),
      chipTheme: _buildChipTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: _textPrimary,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: _textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: _textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: _textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _textSecondary,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() => AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        surfaceTintColor: Colors.transparent,
      );

  static CardThemeData _buildCardTheme() => CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      );

  static InputDecorationTheme _buildInputTheme() => InputDecorationTheme(
        filled: true,
        fillColor: _glassSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor),
        ),
        hintStyle: GoogleFonts.inter(color: _textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: _textSecondary, fontSize: 14),
      );

  static ElevatedButtonThemeData _buildElevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: _glassBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static BottomNavigationBarThemeData _buildBottomNavTheme() =>
      const BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      );

  static NavigationBarThemeData _buildNavigationBarTheme() =>
      NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _primaryColor.withOpacity(0.2),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: _primaryColor);
          }
          return const IconThemeData(color: _textSecondary);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            color: _textSecondary,
          );
        }),
      );

  static ChipThemeData _buildChipTheme() => ChipThemeData(
        backgroundColor: _cardDark,
        selectedColor: _primaryColor.withOpacity(0.3),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: _textPrimary),
        side: const BorderSide(color: _glassBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  // Glass morphism helper for widgets
  static BoxDecoration glassMorphism({
    double borderRadius = 20,
    Color? borderColor,
    Gradient? gradient,
  }) =>
      BoxDecoration(
        color: _glassSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? _glassBorder,
          width: 1,
        ),
        gradient: gradient,
      );

  static const Color primary = _primaryColor;
  static const Color secondary = _secondaryColor;
  static const Color accent = _accentColor;
  static const Color background = _backgroundDark;
  static const Color surface = _surfaceDark;
  static const Color cardColor = _cardDark;
  static const Color glass = _glassSurface;
  static const Color glassBorder = _glassBorder;
  static const Color textPrimary = _textPrimary;
  static const Color textSecondary = _textSecondary;
  static const Color success = _successColor;
  static const Color error = _errorColor;
  static const Color glassSurface = _glassSurface;
}
