// spectrogram_display.dart 
// PWA-only version - no file downloads
import 'package:flutter/material.dart';
import 'web_audio_processing.dart';
import 'spectrogram_widget.dart';
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
    print("🔍 SpectrogramDisplay: loadAndProcessAudio() called with: $audioGSUri");
    try {
      // For PWA, use the web-compatible audio processing
      final result = await WebAudioProcessing.loadAndProcessAudioFromUrl(audioGSUri);
      print("🔍 SpectrogramDisplay: loadAndProcessAudio() SUCCESS - result length: ${result.length}");
      return result;
    } catch (e) {
      print("🔍 SpectrogramDisplay: loadAndProcessAudio() ERROR: $e");
      rethrow;
    }
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
}
