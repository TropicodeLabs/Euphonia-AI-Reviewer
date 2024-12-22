// play_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';

// Import the dictionary from bird_audio_utils.dart
import 'bird_audio_utils.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  /// This will hold our species name (lowercased) => asset path dictionary.
  late final Map<String, String> speciesAudioMap;

  /// For displaying what we scanned
  String scannedData = '';

  /// For playing audio
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Assign the dictionary from bird_audio_utils.dart
    speciesAudioMap = speciesToAssetMap;
  }

  @override
  void reassemble() {
    super.reassemble();
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        qrController?.pauseCamera();
      } else if (Platform.isIOS) {
        qrController?.resumeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Screen'),
      ),
      body: Column(
        children: [
          // The scanner area
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          // The text area for scanned data
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scanned Data: $scannedData'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;

    // Listen for new QR scans
    controller.scannedDataStream.listen((scanData) async {
      final code = scanData.code ?? '';
      if (code.isNotEmpty && code != scannedData) {
        setState(() {
          scannedData = code; // e.g. "Lophoceros fasciatus"
        });
        await _playBirdSound(scannedData);
      }
    });
  }

  Future<void> _playBirdSound(String speciesName) async {
    // Convert scanned species to lowercase to match our dictionary keys
    final lowerName = speciesName.toLowerCase();

    // Attempt to find a matching asset path
    final assetPath = speciesAudioMap[lowerName];
    if (assetPath != null) {
      // Stop any currently playing audio
      await audioPlayer.stop();

      // Play the audio from our assets
      try {
        await audioPlayer.play(
            AssetSource(assetPath)); // Play without capturing a return value
        debugPrint('Playing sound for: $speciesName => $assetPath');
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    } else {
      debugPrint('No sound found for species: $speciesName');
    }
  }
}
