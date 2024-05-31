import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> setDisplayNamePreference(String preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayNamePreference', preference);
  }

  Future<String> getDisplayNamePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('displayNamePreference') ?? 'both';
  }

  // In PreferencesService
  Future<void> setColormapPreference(String preference) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('colormapPreference', preference);
    // Save the preference to persistent storage
  }

  Future<String> getColormapPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('colormapPreference') ?? 'jet';
  }
}

class PreferenceKeys {
  static const String displayNamePreferenceKey = 'displayNamePreference';
  static const String colormapPreferenceKey = 'colormapPreference';
}
