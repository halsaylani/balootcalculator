import 'package:flutter/material.dart';
import '../utils.dart';
import 'package:flutter/services.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = true;

  // Get current theme mode colors
  Color get bgColor => isDarkMode ? Util.darkBgColor : Util.bgColor;
  Color get textColor => isDarkMode ? Util.darkTextColor : Util.textColor;
  Color get text2Color => isDarkMode ? Util.darkText2Color : Util.text2Color;

  Color get cardColor => isDarkMode ? Util.darkCardColor : Util.cardColor;
  Color get btColor => isDarkMode ? Util.darkBtColor : Util.btColor;
  Color get statusColor => isDarkMode ? Util.darkStatusColor : Util.statusColor;

  void updateStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: bgColor,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: bgColor,
      ),
    );
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
