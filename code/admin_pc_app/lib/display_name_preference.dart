import 'package:flutter/material.dart';

class DisplayNamePreference with ChangeNotifier {
  String _preference = 'both';

  String get preference => _preference;

  void setPreference(String newPreference) {
    _preference = newPreference;
    notifyListeners();
  }
}
