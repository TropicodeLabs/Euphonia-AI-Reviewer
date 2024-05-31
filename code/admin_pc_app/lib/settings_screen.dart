import 'package:flutter/material.dart';
import 'preferences_service.dart'; // Import the PreferencesService
import 'package:provider/provider.dart';
import 'display_name_preference.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService();
  String _currentPreference = 'both'; // Default value

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  void _loadPreference() async {
    final preference = await _prefs.getDisplayNamePreference();
    setState(() {
      _currentPreference = preference;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            // Text: 'Display names as',
            Text('Display names', style: Theme.of(context).textTheme.subtitle1),
            // SizedBox(height: 20),
            DropdownButton<String>(
              isExpanded: true,
              value: _currentPreference,
              onChanged: (newValue) async {
                await _prefs.setDisplayNamePreference(newValue!);
                setState(() {
                  _currentPreference = newValue;
                });
                Provider.of<DisplayNamePreference>(context, listen: false)
                    .setPreference(newValue);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preference updated to $newValue'),
                  ),
                );
              },
              items: [
                DropdownMenuItem(
                    value: 'commonName', child: Text('Common Name')),
                DropdownMenuItem(
                    value: 'speciesCode', child: Text('Species Code')),
                DropdownMenuItem(value: 'both', child: Text('Both')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
