import 'example_candidate_model.dart';
import 'package:flutter/material.dart';
import 'spectrogram_widget.dart'; // Import your SpectrogramWidget
import 'dart:typed_data';
import 'audio_processing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'preferences_service.dart';
import 'package:provider/provider.dart';
import 'preferences_model.dart';
import 'tags_model.dart';
import 'card_tools.dart';
import 'spectrogram_display.dart';
import 'card_mutable_data.dart';

import 'package:cloud_functions/cloud_functions.dart';

class ExampleCard extends StatefulWidget {
  ExampleCandidateModel candidate;
  final String projectId;
  int buildCount = 0;

  ExampleCard({
    Key? key,
    required this.candidate,
    required this.projectId,
    required this.buildCount,
  }) : super(key: key ?? ObjectKey(candidate));

  // If you still need a 'withDefaults' constructor, define it explicitly
  ExampleCard.withDefaults({
    Key? key,
    required String projectId,
    required int buildCount,
  }) : this(
          key: key,
          candidate: ExampleCandidateModel(
            audioClipId: "...",
            predictedSpeciesCode: "...",
            predictedCommonName: "...",
            confidence: 0.0,
            audioGSUri: "...",
          ),
          projectId: projectId,
          buildCount: 0,
        );

  @override
  ExampleCardState createState() => ExampleCardState();
}

class ExampleCardState extends State<ExampleCard> {
  late CardMutableData mutableData;

  String _currentDisplayNamePreference = 'both';
  String _currentColormapPreference = 'jet';
  // String _currentDisplayNamePreference = 'both';
  late Future<void> _loadDataFuture; // Future for loading and processing data
  late Future<File> audioDownloadFuture;
  late Future<List> spectrogramFuture;
  // Tags control
  bool toolsVisible = true; // Initially, tools are visible
  bool isTopPosition = true; // Start with top-left position
  bool showTags = true; // Initially, tags are shown
  bool isEditMode = false;
  // box tags control
  bool isBoxTagMode = false;

  bool _isLoadingClips = false;
  String _errorMessage = '';

  List<String> _confidenceLevels = [
    'Somewhat sure',
    'Likely',
    'Completely sure'
  ];

  @override
  void initState() {
    super.initState();
    mutableData = CardMutableData();
    final prefsModel = Provider.of<PreferencesModel>(context, listen: false);
    _currentDisplayNamePreference = prefsModel.displayNamePreference;
    _currentColormapPreference = prefsModel.colormapPreference;
    refreshData();
    // Load audio and process data as soon as the widget is initialized
    // refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final position =
        isTopPosition ? 10.0 : MediaQuery.of(context).size.height - 250.0;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SpectrogramDisplay(
                  key: ValueKey(widget.candidate.audioClipId),
                  audioGSUri: widget.candidate.audioGSUri,
                  colormapPreference: _currentColormapPreference,
                ),
              ),
              Container(
                height: 150,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardToolsWidget(
                        isVisible: toolsVisible,
                        onToggleVisibility: () {
                          setState(() {
                            toolsVisible = !toolsVisible;
                          });
                        },
                        candidate: widget.candidate, // Pass the candidate here
                      ),

                      if (_currentDisplayNamePreference == 'commonName' ||
                          _currentDisplayNamePreference == 'both')
                        Text(
                          widget.candidate.predictedCommonName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      // if (if species code in the list of strings _currentDisplayNamePreference, then
                      // use the species code)
                      if (_currentDisplayNamePreference == 'speciesCode' ||
                          _currentDisplayNamePreference == 'both')
                        Text(
                          widget.candidate.predictedSpeciesCode,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 78, 78, 78),
                            fontSize: 18,
                            // italics
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 5),
                      Text(
                        // widget.candidate.confidence should cast double
                        'Confidence: ${widget.candidate.confidence.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // lets render on top of the tools a button to hide the tools
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(ExampleCard oldWidget) {
    print("didUpdateWidget");
    super.didUpdateWidget(oldWidget);
    if (widget.buildCount != oldWidget.buildCount) {
      refreshData();
    }
  }

  void refreshData() async {
    print("Reloading data...");
    // avoid displaying the wrong info. Should test this
    widget.candidate.updateWith(
      audioClipId: "",
      predictedSpeciesCode: "",
      predictedCommonName: "",
      confidence: 0.0,
      audioGSUri: "",
      spectrogramData: null,
      audioBytes: null,
      localAudioPath: null,
    );

    if (_isLoadingClips) {
      print(
          "Attempted to load clips while already loading. Operation skipped.");
      return null; // Prevent multiple simultaneous loads
    }

    setState(() {
      _isLoadingClips = true;
    });

    print("Loading new candidate data...");

    try {
      // Logic to load new data and create a new candidate instance
      final newCandidate = await loadNewCandidateData(widget.projectId);
      if (newCandidate == null) {
        // Handle error, possibly showing an error indicator
        print("L223 Error loading new candidate: $newCandidate");
        widget.candidate = ExampleCandidateModel(
          audioClipId: "...",
          predictedSpeciesCode: "...",
          predictedCommonName: "...",
          confidence: 0.0,
          audioGSUri: "...",
        );
        return;
      }
      setState(() {
        widget.candidate = newCandidate; // Replace with the new instance
        print("New candidate loaded: ${widget.candidate.audioClipId}");
        // Stop loading indicator
      });
    } catch (error) {
      print("Error loading new candidate: $error");
      setState(() {
        // Handle error, possibly showing an error indicator
      });
    } finally {
      setState(() {
        _isLoadingClips = false;
      });
    }
  }

  Future<ExampleCandidateModel?> loadNewCandidateData(String projectId) async {
    print("Starting to load audio clips...");

    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('getRandomClips');
      final results = await callable.call({'projectId': projectId});
      final List<dynamic> data = results.data;

      if (data.isEmpty) {
        print("No audio clips found.");
        _errorMessage = "No audio clips found.";
        return null;
      }

      final List<ExampleCandidateModel> clips = data.map((dynamic item) {
        Map<String, dynamic> clipData = Map<String, dynamic>.from(item);
        return ExampleCandidateModel.fromJson(clipData['id'], clipData);
      }).toList();

      print(clips.length);

      if (clips.length > 1) {
        print("WARNING More than one clip found");
      }

      ExampleCandidateModel _candidate =
          clips[0]; // Return the first clip in the list

      print(
          "EXAMPLECARD Loaded ${clips.length} clips. QueueDeck now has ${clips.length} items.");

      return _candidate;
    } catch (e) {
      print("Error fetching audio clips: $e");
      _errorMessage = "Error fetching audio clips: $e";
    }

    return null;
  }
}
