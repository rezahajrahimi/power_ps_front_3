import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static Color primaryColor = const Color(0xFF2697FF);
  static Color secondaryColor = const Color(0xFF2A2D3E);
  static Color bgColor = const Color(0xFF212332);

  static double defaultPadding = 16.0;
  static double strokeWidth = 0.4;
  static Color activeStatus = Colors.white10;
  static Color deactiveStatus = Colors.white54;

  static void applyBranding({
    String? primaryHex,
    String? secondaryHex,
    String? backgroundHex,
  }) {
    final primary = _colorFromHex(primaryHex);
    final secondary = _colorFromHex(secondaryHex);
    final background = _colorFromHex(backgroundHex);
    if (primary != null) primaryColor = primary;
    if (secondary != null) secondaryColor = secondary;
    if (background != null) bgColor = background;
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    final intVal = int.tryParse(value, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  static Color secendColor = const Color(0xFF2A2D3E);
  static Color searchBarColor = const Color.fromARGB(255, 226, 229, 236);
  static TextStyle mainTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black));
  static TextStyle secendTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(fontSize: 18, color: Colors.black));
  static TextStyle thirdTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(fontSize: 16, color: Colors.white70));
  static TextStyle fourthTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(fontSize: 13, color: Colors.white));
  static TextStyle appBarTitleStyle = GoogleFonts.vazirmatn(
      textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppStyle.primaryColor));
  static TextStyle appBarLocationStyle = GoogleFonts.vazirmatn(
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppStyle.primaryColor));
  static TextStyle subTitleStyle = GoogleFonts.vazirmatn(
      textStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w400, color: secendColor));
  static TextStyle priceTitleStyle = GoogleFonts.vazirmatn(
      textStyle: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor));
  static TextStyle sectionTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
  static TextStyle sectionTitleStyle2 = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white));
  static TextStyle sectionSmallTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(fontSize: 16, color: Colors.black));
  static TextStyle sectionFoodCategoryTitleStyle = GoogleFonts.vazirmatn(
      textStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16));
  static const mobileBackgroundColor = Color.fromRGBO(0, 0, 0, 1);
  static const webBackgroundColor = Color.fromRGBO(18, 18, 18, 1);
  static const mobileSearchColor = Color.fromRGBO(38, 38, 38, 1);
  static const blueColor = Color.fromRGBO(0, 149, 246, 1);
  static ButtonStyle defaultButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      elevation: WidgetStateProperty.all(2.5));
  static ButtonStyle alertButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.grey,
    foregroundColor: Colors.black,
    padding: EdgeInsets.symmetric(
      horizontal: AppStyle.defaultPadding * 1.5,
      vertical: AppStyle.defaultPadding / 2,
    ),
  );
}
