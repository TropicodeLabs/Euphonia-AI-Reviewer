import 'package:flutter/material.dart';

class UserConfidenceSelector extends StatefulWidget {
  final Function(String confidence) onSelected;

  const UserConfidenceSelector({Key? key, required this.onSelected})
      : super(key: key);

  @override
  _UserConfidenceSelectorState createState() => _UserConfidenceSelectorState();
}

class _UserConfidenceSelectorState extends State<UserConfidenceSelector> {
  // Use a more descriptive initial value and icon to match your confidence levels
  String _selectedConfidence = 'Completely sure'; // Default value
  IconData _selectedIcon = Icons.flag; // Default icon

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Make the column wrap content
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('How sure are you?',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)), // Title
                ),
                ListTile(
                  leading: Icon(Icons.flag, color: Colors.red),
                  title: Text('Somewhat sure'),
                  onTap: () =>
                      _selectOption('Somewhat sure', Icons.flag, Colors.red),
                ),
                ListTile(
                  leading: Icon(Icons.flag, color: Colors.yellow),
                  title: Text('Likely'),
                  onTap: () =>
                      _selectOption('Likely', Icons.flag, Colors.yellow),
                ),
                ListTile(
                  leading: Icon(Icons.flag, color: Colors.blue),
                  title: Text('Completely sure'),
                  onTap: () =>
                      _selectOption('Completely sure', Icons.flag, Colors.blue),
                ),
              ],
            ),
          );
        });
  }

  void _selectOption(String confidence, IconData icon, Color color) {
    Navigator.pop(context); // Close the modal sheet
    setState(() {
      _selectedConfidence = confidence;
      _selectedIcon = icon;
    });
    widget.onSelected(confidence); // Call the callback function
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showOptions(context),
      child: Icon(_selectedIcon, color: _getIconColor(), size: 35),
    );
  }

  Color _getIconColor() {
    // This function now directly uses the icon color set during selection
    switch (_selectedConfidence) {
      case 'Somewhat sure':
        return Colors.red;
      case 'Likely':
        return Colors.yellow;
      case 'Completely sure':
        return Colors.blue;
      default:
        return Colors.grey; // Default color if none matches
    }
  }
}
