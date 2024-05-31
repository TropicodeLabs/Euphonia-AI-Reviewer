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
}
