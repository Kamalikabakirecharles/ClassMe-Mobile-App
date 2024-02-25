import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _currentTheme = _greenTheme;

  bool _showStatusIndicators = true;
  
  bool get showStatusIndicators => _showStatusIndicators;

  set showStatusIndicators(bool value) {
    _showStatusIndicators = value;
    notifyListeners();
  }
  // Color constants
  static const Color greenPrimaryColor = Colors.green;
  static const Color bluePrimaryColor = Colors.blue;
  static const Color redPrimaryColor = Colors.red; // New color
  static const Color purplePrimaryColor = Colors.purple; // New color
  static const Color orangePrimaryColor = Colors.orange; // New color
  static const Color whiteColor = Colors.white;

  // Available themes list
  static final List<ThemeData> availableThemes = [
    _greenTheme,
    _blueTheme,
    _redTheme,
    _purpleTheme,
    _orangeTheme,
  ];

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeIndex');
    _currentTheme = _getTheme(themeIndex);
    notifyListeners();
  }

  void _saveTheme(int themeIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeIndex', themeIndex);
  }

  // Method to set the selected theme
  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    int themeIndex = availableThemes.indexOf(theme);
    _saveTheme(themeIndex);
    notifyListeners();
  }

  void toggleTheme() {
  _currentTheme = (_currentTheme == _greenTheme)
      ? _blueTheme
      : (_currentTheme == _blueTheme)
          ? _redTheme
          : (_currentTheme == _redTheme)
              ? _purpleTheme
              : (_currentTheme == _purpleTheme)
                  ? _orangeTheme
                  : _greenTheme;

  int themeIndex = (_currentTheme == _greenTheme)
      ? 0
      : (_currentTheme == _blueTheme)
          ? 1
          : (_currentTheme == _redTheme)
              ? 2
              : (_currentTheme == _purpleTheme) ? 3 : 4;

  _saveTheme(themeIndex);
  notifyListeners();
}


  ThemeData _getTheme(int? themeIndex) {
  if (themeIndex == null) {
    return _greenTheme; // Provide a default theme if themeIndex is null
  }

  final totalThemes = 5;
  final adjustedIndex = themeIndex % totalThemes;

  switch (adjustedIndex) {
    case 1:
      return _blueTheme;
    case 2:
      return _redTheme;
    case 3:
      return _purpleTheme;
    case 4:
      return _orangeTheme;
    default:
      return _greenTheme;
  }
}


  static final ThemeData _greenTheme = ThemeData(
    primaryColor: greenPrimaryColor,
    hintColor: whiteColor,
    backgroundColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    appBarTheme: AppBarTheme(
      backgroundColor: greenPrimaryColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: greenPrimaryColor,
      selectedItemColor: whiteColor,
      unselectedItemColor: whiteColor,
    ),
  );

  static final ThemeData _blueTheme = ThemeData(
    primaryColor: bluePrimaryColor,
    hintColor: whiteColor,
    backgroundColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    appBarTheme: AppBarTheme(
      backgroundColor: bluePrimaryColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bluePrimaryColor,
      selectedItemColor: whiteColor,
      unselectedItemColor: whiteColor,
    ),
  );

  static final ThemeData _redTheme = ThemeData(
    primaryColor: redPrimaryColor,
    hintColor: whiteColor,
    backgroundColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    appBarTheme: AppBarTheme(
      backgroundColor: redPrimaryColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: redPrimaryColor,
      selectedItemColor: whiteColor,
      unselectedItemColor: whiteColor,
    ),
  );

  static final ThemeData _purpleTheme = ThemeData(
    primaryColor: purplePrimaryColor,
    hintColor: whiteColor,
    backgroundColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    appBarTheme: AppBarTheme(
      backgroundColor: purplePrimaryColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: purplePrimaryColor,
      selectedItemColor: whiteColor,
      unselectedItemColor: whiteColor,
    ),
  );

  static final ThemeData _orangeTheme = ThemeData(
    primaryColor: orangePrimaryColor,
    hintColor: whiteColor,
    backgroundColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    appBarTheme: AppBarTheme(
      backgroundColor: orangePrimaryColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: orangePrimaryColor,
      selectedItemColor: whiteColor,
      unselectedItemColor: whiteColor,
    ),
  );
}
