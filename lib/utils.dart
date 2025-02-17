import 'package:flutter/material.dart';

class Util {
  //light theme
  static const bgColor = Color(0xFFFFFFFF);
  static const textColor = Color(0xFF000000);
  static const text2Color = Color(0xFF000000);

  static const cardColor = Color(0xFFF7F8FA); //Color(0xFFF2F1F5);
  static const statusColor = Color(0xFFF3F0FB);
  static const btColor = Color(0xFF7460EE);

  //dark theme
  static const darkBgColor = Color(0xFF000000);
  static const darkTextColor = Color(0xFFFFFFFF);
  static const darkText2Color = Color(0xB3FFFFFF);

  static const darkCardColor = Color(0xFF1C1C1E);
  static const darkBtColor = Color(0xFF3E3E40);
  static const darkStatusColor = Color(0xFF2A2D3E);

  //get height of screen
  static double height(BuildContext c) {
    var height = MediaQuery.of(c).size.height;
    return height;
  }

  //get width of screen
  static double width(BuildContext c) {
    var width = MediaQuery.of(c).size.width;
    return width;
  }

  // Navigate back
  void pop(BuildContext context) {
    Navigator.pop(context);
  }

  // Navigate to a screen
  void goTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  //hideKeyboard
  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  String convertArabicToEnglishNumbers(String input) {
    const Map<String, String> arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9'
    };

    return input.split('').map((char) => arabicToEnglish[char] ?? char).join();
  }

  static String getFormattedDate() {
    DateTime now = DateTime.now();
    return "${now.day} ${_getMonthAbbreviation(now.month)} ${now.year}";
  }

  /// Returns the abbreviated month name
  static String _getMonthAbbreviation(int month) {
    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}
