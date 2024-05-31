import 'package:flutter/material.dart';
import 'preferences_service.dart'; // Import the PreferencesService
import 'package:provider/provider.dart';
import 'preferences_model.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService();
  String _currentDisplayNamePreference =
      'both'; // Default value for display names
  String _currentColormapPreference = 'grayscale'; // Default value for colormap

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  void _loadPreference() async {
    final displayNamePreference = await _prefs.getDisplayNamePreference();
    final colormapPreference = await _prefs
        .getColormapPreference(); // Ensure this method is defined in your PreferencesService
    setState(() {
      _currentDisplayNamePreference = displayNamePreference;
      _currentColormapPreference = colormapPreference;
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
              value: _currentDisplayNamePreference,
              onChanged: (newValue) async {
                await Provider.of<PreferencesModel>(context, listen: false)
                    .setDisplayNamePreference(newValue!);
                setState(() {
                  _currentDisplayNamePreference = newValue;
                });
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
            const SizedBox(height: 20), // Add some spacing
            Text('Spectrogram Colormap',
                style: Theme.of(context).textTheme.subtitle1),
            DropdownButton<String>(
              isExpanded: true,
              value: _currentColormapPreference,
              onChanged: (newValue) async {
                await Provider.of<PreferencesModel>(context, listen: false)
                    .setColormapPreference(newValue!);
                setState(() {
                  _currentColormapPreference = newValue;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preference updated to $newValue'),
                  ),
                );
                // Update provider or use another method to propagate the change
              },
              items: [
                DropdownMenuItem(value: 'grayscale', child: Text('Grayscale')),
                DropdownMenuItem(value: 'jet', child: Text('Jet')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
