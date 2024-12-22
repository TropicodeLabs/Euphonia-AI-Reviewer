import 'dart:io';
import 'package:flutter/material.dart';
import 'audio_processing.dart'; // Assuming this contains your audio processing logic
import 'spectrogram_widget.dart'; // Your existing widget for displaying the spectrogram
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'preferences_model.dart';
import 'package:provider/provider.dart';

class SpectrogramDisplay extends StatefulWidget {
  final String audioGSUri;
  final String colormapPreference;

  const SpectrogramDisplay({
    Key? key,
    required this.audioGSUri,
    required this.colormapPreference,
  }) : super(key: key);

  @override
  _SpectrogramDisplayState createState() => _SpectrogramDisplayState();
}

class _SpectrogramDisplayState extends State<SpectrogramDisplay> {
  late Future<List> _spectrogramFuture;

  @override
  void initState() {
    super.initState();
    _spectrogramFuture = loadAndProcessAudio(widget.audioGSUri);
  }

  Future<List> loadAndProcessAudio(String audioGSUri) async {
    // Logic to download audio file and process it for spectrogram data
    File audioFile = await downloadAudioFile(audioGSUri);
    return AudioProcessing.loadAndProcessAudioFromFile(audioFile);
  }

  void _loadSpectrogramData() {
    _spectrogramFuture = loadAndProcessAudio(widget.audioGSUri);
  }

  @override
  void didUpdateWidget(SpectrogramDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.audioGSUri != oldWidget.audioGSUri) {
      // If the audio source has changed, reload the spectrogram data
      _loadSpectrogramData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the colormapPreference here, so it gets the latest value on rebuild
    final colormapPreference =
        Provider.of<PreferencesModel>(context).colormapPreference;

    return FutureBuilder<List>(
      future: _spectrogramFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          // Pass the latest colormapPreference to the SpectrogramWidget
          return SpectrogramWidget(
            spectrogram: snapshot.data![0],
            audioBytes: snapshot.data![1],
            localAudioPath: snapshot.data![2],
            contrastFactor: 0.2,
            brightnessFactor: 1.0,
            colormap: colormapPreference, // Updated to use the latest value
          );
        } else if (snapshot.hasError) {
          return Text("Error loading spectrogram");
        }
        return CircularProgressIndicator(); // Show loading indicator while waiting
      },
    );
  }

  Future<File> downloadAudioFile(String audioGSUri) async {
    final RegExp regExp = RegExp(r'gs://(.*?)/(.*)');
    final match = regExp.firstMatch(audioGSUri);

    if (match != null) {
      final String bucketName = match.group(1)!;
      final String filePath = match.group(2)!;

      final ref = FirebaseStorage.instanceFor(bucket: 'gs://$bucketName')
          .ref()
          .child(filePath);

      // Use the path_provider plugin to get a temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      // Construct the full path for the file to ensure directories are created
      // for the localpath lets only use the basename in that tempdir

      final String localFilePath = p.join(tempDir.path, p.basename(filePath));

      // Create the directory where the file will be saved
      final File file = File(localFilePath);
      await file.parent.create(recursive: true); // Ensure the directory exists

      // Download the file
      await ref.writeToFile(file);

      return file;
    } else {
      throw Exception('Invalid GS URI');
    }
  }
}
