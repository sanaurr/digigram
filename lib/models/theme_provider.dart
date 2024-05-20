import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Brightness _mode = Brightness.light;
  set mode(Brightness newTheme) {
    _mode = newTheme;
    notifyListeners();
  }

  Brightness get mode => _mode;
}
