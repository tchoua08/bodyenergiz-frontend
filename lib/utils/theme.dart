import 'package:flutter/material.dart';

class AppTheme {
  // ---- OFFICIAL BODYENERGIZ COLORS ----
  static const Color primaryTeal = Color(0xFF0ED2F7); // Cyan / Teal énergique
  static const Color darkBlue = Color(0xFF0072BB);   // Bleu profond du logo
  static const Color lightBlue = Color(0xFF4FC3F7);  // Bleu clair secondaire

  static const Color auraGreen = Color(0xFF00FFAB);
  static const Color auraRed = Color(0xFFFF5E5E);
  static const Color auraPurple = Color(0xFFB388FF);
  static const Color auraGold = Color(0xFFFFD700);

  // ---- MATERIAL THEME ----
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: darkBlue,
    ),
  );

  // ---- GRADIENT MAIN ----
  static BoxDecoration mainGradient = const BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryTeal, darkBlue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ---- GRADIENT BUTTON WIDGET ----
  static Widget gradientButton({
    required String text,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryTeal, darkBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ---- AURA COLOR PAR LOGIQUE ----
  static Color colorFromAura(String aura) {
    switch (aura.toLowerCase()) {
      case "green":
      case "vert":
        return auraGreen;

      case "red":
      case "rouge":
        return auraRed;

      case "purple":
      case "violet":
        return auraPurple;

      case "gold":
      case "doré":
        return auraGold;

      default:
        return primaryTeal;
    }
  }
}


