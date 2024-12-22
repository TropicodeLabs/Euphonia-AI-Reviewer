// audio_processing.dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'package:wav/wav.dart';
import 'dart:io';

class AudioProcessing {
  static Future<List> loadAndProcessAudioFromFile(File file,
      {int chunkSize = 512, int chunkStride = 32}) async {
    final bytes = await file.readAsBytes();
    // final Uint8List bytes = data.buffer.asUint8List();
    final audio =
        Wav.read(bytes).toMono(); // Adjust based on your WAV handling package

    final stft = STFT(chunkSize, Window.hanning(chunkSize));
    final spectrogramData = <Float64List>[];

    stft.run(audio, (Float64x2List freq) {
      spectrogramData.add(freq.discardConjugates().magnitudes());
    }, chunkStride);

    // return spectrogramData;
    // return both the spectrogramData and the bytes
    // return also the path of the file
    return [spectrogramData, bytes, file.path];
  }
}
