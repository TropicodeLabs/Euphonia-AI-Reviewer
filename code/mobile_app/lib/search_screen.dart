import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'example_candidate_model.dart';
import 'spectrogram_widget.dart';
import 'preferences_model.dart';

class SearchScreen extends StatefulWidget {
  final List<String> speciesCodes;
  final List<String> commonNames;
  final ExampleCandidateModel? candidate;

  const SearchScreen({
    Key? key,
    required this.commonNames,
    required this.speciesCodes,
    required this.candidate,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  List<int> filteredIndexes = []; // Track indexes of filtered items

  String _currentDisplayNamePreference = 'both';
  String _currentColormapPreference = 'jet';

  @override
  void initState() {
    super.initState();

    // Initially, all names are shown
    filteredIndexes =
        List.generate(widget.commonNames.length, (index) => index);

    // Defer the loading of preferences until after the initial build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  void _loadPreferences() {
    // Access PreferencesModel provided via Provider
    final prefsModel = Provider.of<PreferencesModel>(context, listen: false);
    setState(() {
      _currentDisplayNamePreference = prefsModel.displayNamePreference;
      _currentColormapPreference = prefsModel.colormapPreference;
    });

    void _loadPreferences() async {
      final prefsModel = Provider.of<PreferencesModel>(context, listen: false);
      // Assuming getColormapPreference and getDisplayNamePreference are updated to update state internally or you manage async call properly.
      await prefsModel.getColormapPreference();
      await prefsModel.getDisplayNamePreference();
      setState(() {
        _currentDisplayNamePreference = prefsModel.displayNamePreference;
        _currentColormapPreference = prefsModel.colormapPreference;
      });
    }
  }

  void _filterNames(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      filteredIndexes = widget.commonNames
          .asMap()
          .entries
          .where((entry) {
            final commonName = entry.value.toLowerCase();
            final speciesCode = widget.speciesCodes[entry.key].toLowerCase();
            return commonName.contains(_searchQuery) ||
                speciesCode.contains(_searchQuery);
          })
          .map((entry) => entry.key)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showCommonName = _currentDisplayNamePreference == 'both' ||
        _currentDisplayNamePreference == 'commonName';
    final bool showSpeciesCode = _currentDisplayNamePreference == 'both' ||
        _currentDisplayNamePreference == 'speciesCode';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context,
            null); // Assuming null means "do not move to the next card"
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, null),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: widget.candidate?.spectrogramData != null &&
                      widget.candidate?.audioBytes != null
                  ? SpectrogramWidget(
                      spectrogram: widget.candidate?.spectrogramData!,
                      audioBytes: widget.candidate?.audioBytes!,
                      localAudioPath: widget.candidate?.localAudioPath,
                      contrastFactor: 0.2,
                      brightnessFactor: 1.0,
                      colormap: _currentColormapPreference,
                    )
                  : Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search label',
                  hintText: 'Type to search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                onChanged: _filterNames,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredIndexes.length,
                itemBuilder: (context, index) {
                  final originalIndex = filteredIndexes[index];
                  final commonName = widget.commonNames[originalIndex];
                  final speciesCode = widget.speciesCodes[originalIndex];
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: showCommonName ? commonName : '',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          if (showCommonName && showSpeciesCode)
                            TextSpan(text: '\n'),
                          if (showSpeciesCode)
                            TextSpan(
                              text: speciesCode,
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.pop(context, originalIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
