// web_audio_service.dart
// PWA-only audio service - no mobile support needed
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WebAudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  /// Play audio from a Firebase Storage URI by streaming
  static Future<void> playAudioFromGSUri(String audioGSUri) async {
    try {
      // Stop any currently playing audio
      await _audioPlayer.stop();
      
      // Get download URL and stream directly
      final downloadUrl = await _getDownloadUrlFromGSUri(audioGSUri);
      await _audioPlayer.play(UrlSource(downloadUrl));
      debugPrint('Streaming audio from: $downloadUrl');
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }
  
  /// Play audio from asset
  static Future<void> playAudioFromAsset(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
      debugPrint('Playing audio from asset: $assetPath');
    } catch (e) {
      debugPrint('Error playing audio from asset: $e');
      rethrow;
    }
  }
  
  /// Play audio directly from an HTTPS URL (for download URLs)
  static Future<void> playAudioFromUrl(String url) async {
    try {
      await _audioPlayer.stop();
      
      print("🔍 WebAudioService: Attempting to play URL: $url");
      print("🔍 WebAudioService: File extension: ${url.split('.').last.split('?').first}");
      
      // Try to set the source first
      await _audioPlayer.setSource(UrlSource(url));
      print("🔍 WebAudioService: Source set successfully");
      
      // Then play
      await _audioPlayer.resume();
      print("🔍 WebAudioService: Playback started");
      
      debugPrint('Playing audio from URL: $url');
    } catch (e) {
      print("🔍 WebAudioService: Error in playAudioFromUrl: $e");
      print("🔍 WebAudioService: Error type: ${e.runtimeType}");
      
      // Log specific error details for WAV format issues
      if (e.toString().contains('Format error')) {
        print("🔍 WebAudioService: This appears to be a format compatibility issue");
        print("🔍 WebAudioService: WAV files may not be supported in web browsers via Firebase Storage");
        print("🔍 WebAudioService: Consider converting audio files to MP3 or AAC for web compatibility");
      }
      
      debugPrint('Error playing audio from URL: $e');
      rethrow;
    }
  }
  
  /// Convert Firebase Storage URI to download URL
  static Future<String> _getDownloadUrlFromGSUri(String audioGSUri) async {
    final RegExp regExp = RegExp(r'gs://(.*?)/(.*)');
    final match = regExp.firstMatch(audioGSUri);
    
    if (match != null) {
      final String bucketName = match.group(1)!;
      final String filePath = match.group(2)!;
      
      final ref = FirebaseStorage.instanceFor(bucket: 'gs://$bucketName')
          .ref()
          .child(filePath);
      
      return await ref.getDownloadURL();
    } else {
      throw Exception('Invalid GS URI: $audioGSUri');
    }
  }
  
  /// Stop currently playing audio
  static Future<void> stop() async {
    await _audioPlayer.stop();
  }
  
  /// Dispose of the audio player
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
