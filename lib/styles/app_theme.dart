import 'package:flutter/material.dart';

class AppStyle {
  static Color primaryColor = const Color(0xFF2697FF);
  static Color secondaryColor = const Color(0xFF2A2D3E);
  static Color bgColor = const Color(0xFF212332);

  static double defaultPadding = 16.0;
  static double strokeWidth = 0.4;
  static Color activeStatus = Colors.white10;
  static Color deactiveStatus = Colors.white54;

  static Color secendColor = const Color(0xFF2A2D3E);
  static Color searchBarColor = const Color.fromARGB(255, 226, 229, 236);
  static TextStyle mainTitleStyle = const TextStyle(
      fontFamily: "Vazir",
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 18);
  static TextStyle secendTitleStyle =
      const TextStyle(fontFamily: "Vazir", color: Colors.black, fontSize: 18);
  static TextStyle thirdTitleStyle =
      const TextStyle(fontFamily: "Vazir", color: Colors.white70, fontSize: 16);
  // static TextStyle thirdTitleStyle =
  //     const TextStyle(fontFamily: "Vazir", color: Colors.grey, fontSize: 16);
  static TextStyle fourthTitleStyle =
      const TextStyle(fontFamily: "Vazir", color: Colors.white, fontSize: 13);
  static TextStyle appBarTitleStyle = TextStyle(
      fontFamily: "Vazir",
      color: AppStyle.primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 16);
  static TextStyle appBarLocationStyle = TextStyle(
      fontFamily: "Vazir",
      color: AppStyle.primaryColor,
      fontWeight: FontWeight.normal,
      fontSize: 14);
  static TextStyle subTitleStyle = TextStyle(
      fontFamily: "Vazir",
      color: secendColor,
      fontWeight: FontWeight.w400,
      fontSize: 18);
  static TextStyle priceTitleStyle = TextStyle(
      fontFamily: "Vazir",
      color: primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 32);
  static TextStyle sectionTitleStyle = const TextStyle(
      fontFamily: "Vazir",
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20);
  static TextStyle sectionTitleStyle2 = const TextStyle(
      fontFamily: "Vazir",
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20);
  static TextStyle sectionSmallTitleStyle =
      const TextStyle(fontFamily: "Vazir", color: Colors.black, fontSize: 16);
  static TextStyle sectionFoodCategoryTitleStyle = const TextStyle(
      fontFamily: "Vazir",
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 16);
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
  // static ButtonStyle alertButtonStyle = ButtonStyle(
  //     backgroundColor: MaterialStateProperty.all(Colors.grey),
  //     foregroundColor: MaterialStateProperty.all(Colors.black),
  //     elevation: MaterialStateProperty.all(2.5));
}
