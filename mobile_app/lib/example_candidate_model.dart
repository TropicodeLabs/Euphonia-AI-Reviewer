import 'dart:typed_data';
import 'tags_model.dart';

class ExampleCandidateModel {
  final String audioClipId;
  final String predictedSpeciesCode;
  final String predictedCommonName;
  final double confidence;
  final String audioGSUri;
  List<Float64List>? spectrogramData;
  Uint8List? audioBytes;
  String? localAudioPath;

  ExampleCandidateModel({
    required this.audioClipId,
    required this.predictedSpeciesCode,
    required this.predictedCommonName,
    required this.confidence,
    required this.audioGSUri,
    this.spectrogramData,
    this.audioBytes,
    this.localAudioPath,
  });

// Assuming `json` is the larger JSON object containing all clips
// and `key` is the current audioClipId you're iterating over
  factory ExampleCandidateModel.fromJson(
      String key, Map<String, dynamic> clipData) {
    // var clipData = json[key];
    return ExampleCandidateModel(
      audioClipId: key,
      predictedSpeciesCode: clipData['predictedSpeciesCode'] ?? '',
      predictedCommonName: clipData['predictedCommonName'] ?? '',
      confidence: clipData['confidence']?.toDouble() ?? 0.0,
      audioGSUri: clipData['audioGSUri'] ?? '',
      // Handle spectrogramData and audioBytes as needed
    );
  }

  ExampleCandidateModel updateWith({
    String? audioClipId,
    String? predictedSpeciesCode,
    String? predictedCommonName,
    double? confidence,
    String? audioGSUri,
    List<Float64List>? spectrogramData,
    Uint8List? audioBytes,
    String? localAudioPath,
  }) {
    return ExampleCandidateModel(
      audioClipId: audioClipId ?? this.audioClipId,
      predictedSpeciesCode: predictedSpeciesCode ?? this.predictedSpeciesCode,
      predictedCommonName: predictedCommonName ?? this.predictedCommonName,
      confidence: confidence ?? this.confidence,
      audioGSUri: audioGSUri ?? this.audioGSUri,
      spectrogramData: spectrogramData ?? this.spectrogramData,
      audioBytes: audioBytes ?? this.audioBytes,
      localAudioPath: localAudioPath ?? this.localAudioPath,
    );
  }
}
