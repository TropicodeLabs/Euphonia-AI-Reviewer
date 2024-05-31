import 'package:flutter/material.dart';
import 'preferences_service.dart';

class PreferencesModel with ChangeNotifier {
  String _colormapPreference = 'jet';
  String _displayNamePreference = 'both';

  PreferencesModel() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefsService = PreferencesService();
    _displayNamePreference = await prefsService.getDisplayNamePreference();
    _colormapPreference = await prefsService.getColormapPreference();
    notifyListeners();
  }

  String get colormapPreference => _colormapPreference;

  Future<void> getColormapPreference() async {
    final prefs = PreferencesService();
    _colormapPreference = await prefs.getColormapPreference();
    notifyListeners();
  }

  Future<void> setColormapPreference(String value) async {
    final prefs = PreferencesService();
    await prefs.setColormapPreference(value);
    _colormapPreference = value;
    notifyListeners();
  }

  String get displayNamePreference => _displayNamePreference;

  Future<void> getDisplayNamePreference() async {
    final prefs = PreferencesService();
    _displayNamePreference = await prefs.getDisplayNamePreference();
    notifyListeners();
  }

  Future<void> setDisplayNamePreference(String value) async {
    final prefs = PreferencesService();
    await prefs.setDisplayNamePreference(value);
    _displayNamePreference = value;
    notifyListeners();
  }
}
