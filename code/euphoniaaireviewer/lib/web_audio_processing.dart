// web_audio_processing.dart
// PWA-only audio processing - no file downloads
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:math' as math;

class WebAudioProcessing {
  /// For PWA, fetch audio bytes directly without saving to local file
  static Future<List> loadAndProcessAudioFromUrl(String audioGSUri) async {
    print("🔍 WebAudioProcessing: loadAndProcessAudioFromUrl() called with: $audioGSUri");
    
    try {
      print("🔍 WebAudioProcessing: Step 1 - Getting download URL...");
      final downloadUrl = await _getDownloadUrlFromGSUri(audioGSUri);
      print("🔍 WebAudioProcessing: Step 1 COMPLETE - Download URL obtained: $downloadUrl");
      
      print("🔍 WebAudioProcessing: Step 2 - Fetching audio bytes...");
      final audioBytes = await _fetchAudioBytesFromGSUri(audioGSUri);
      print("🔍 WebAudioProcessing: Step 2 COMPLETE - Audio bytes fetched, size: ${audioBytes.length}");
      
      // For PWA, we'll create a simple mock spectrogram
      // In a production app, you might want to implement Web Audio API
      // for real spectrogram generation, but for now this provides the UI structure
      print("🔍 WebAudioProcessing: Step 3 - Generating mock spectrogram...");
      final mockSpectrogramData = _generateMockSpectrogram();
      print("🔍 WebAudioProcessing: Step 3 COMPLETE - Mock spectrogram generated, frames: ${mockSpectrogramData.length}");
      
      final result = [mockSpectrogramData, audioBytes, downloadUrl];
      print("🔍 WebAudioProcessing: SUCCESS - Returning result with ${result.length} elements");
      print("🔍 WebAudioProcessing: Result types: ${result.map((e) => e.runtimeType).toList()}");
      return result;
    } catch (e, stackTrace) {
      print("🔍 WebAudioProcessing: ERROR in loadAndProcessAudioFromUrl: $e");
      print("🔍 WebAudioProcessing: ERROR Type: ${e.runtimeType}");
      print("🔍 WebAudioProcessing: STACK TRACE: $stackTrace");
      rethrow;
    }
  }
  
  /// Fetch audio bytes without saving to file
  static Future<Uint8List> _fetchAudioBytesFromGSUri(String audioGSUri) async {
    print("🔍 WebAudioProcessing: _fetchAudioBytesFromGSUri() called");
    
    try {
      final downloadUrl = await _getDownloadUrlFromGSUri(audioGSUri);
      print("🔍 WebAudioProcessing: Using download URL for fetch: $downloadUrl");
      
      // Check if URL is accessible by testing it first
      print("🔍 WebAudioProcessing: Testing URL accessibility...");
      print("🔍 WebAudioProcessing: You can test this URL manually in browser console:");
      print("🔍 WebAudioProcessing: fetch('$downloadUrl').then(r => console.log('Status:', r.status, 'OK:', r.ok))");
      
      // Use browser's fetch API to get the audio data
      print("🔍 WebAudioProcessing: Starting fetch request...");
      print("🔍 WebAudioProcessing: Full URL being fetched: $downloadUrl");
      
      // Try with no-cors mode first as fallback
      dynamic response;
      try {
        print("🔍 WebAudioProcessing: Attempting fetch with CORS mode...");
        response = await html.window.fetch(downloadUrl, {
          'mode': 'cors',
          'credentials': 'omit',
          'headers': {
            'Accept': '*/*',
          }
        });
        print("🔍 WebAudioProcessing: CORS fetch successful");
      } catch (corsError) {
        print("🔍 WebAudioProcessing: CORS fetch failed: $corsError");
        print("🔍 WebAudioProcessing: Attempting fetch with no-cors mode...");
        response = await html.window.fetch(downloadUrl, {
          'mode': 'no-cors',
        });
        print("🔍 WebAudioProcessing: no-cors fetch attempted");
      }
      print("🔍 WebAudioProcessing: Fetch response status: ${response.status}");
      print("🔍 WebAudioProcessing: Fetch response ok: ${response.ok}");
      print("🔍 WebAudioProcessing: Fetch response statusText: ${response.statusText}");
      
      if (!response.ok) {
        throw Exception("HTTP ${response.status}: ${response.statusText}");
      }
      
      print("🔍 WebAudioProcessing: Getting arrayBuffer...");
      final arrayBuffer = await response.arrayBuffer();
      print("🔍 WebAudioProcessing: ArrayBuffer size: ${arrayBuffer.byteLength}");
      
      final result = Uint8List.view(arrayBuffer);
      print("🔍 WebAudioProcessing: Uint8List created, length: ${result.length}");
      return result;
    } catch (e, stackTrace) {
      print("🔍 WebAudioProcessing: ERROR in _fetchAudioBytesFromGSUri: $e");
      print("🔍 WebAudioProcessing: ERROR Type: ${e.runtimeType}");
      print("🔍 WebAudioProcessing: STACK TRACE: $stackTrace");
      
      // For now, return empty bytes to allow the app to continue with mock spectrogram
      print("🔍 WebAudioProcessing: Returning empty bytes as fallback");
      print("🔍 WebAudioProcessing: This is likely a CORS issue with Firebase Storage URLs");
      print("🔍 WebAudioProcessing: The app will still work with mock spectrogram and streaming audio");
      print("🔍 WebAudioProcessing: Audio playback should work when clicking the spectrogram");
      return Uint8List(0);
    }
  }
  
  /// Convert Firebase Storage URI to download URL
  static Future<String> _getDownloadUrlFromGSUri(String audioGSUri) async {
    print("🔍 WebAudioProcessing: _getDownloadUrlFromGSUri() called with: $audioGSUri");
    
    try {
      final RegExp regExp = RegExp(r'gs://(.*?)/(.*)');
      final match = regExp.firstMatch(audioGSUri);
      
      if (match != null) {
        final String bucketName = match.group(1)!;
        final String filePath = match.group(2)!;
        print("🔍 WebAudioProcessing: Parsed bucket: $bucketName, path: $filePath");
        
        final ref = FirebaseStorage.instanceFor(bucket: 'gs://$bucketName')
            .ref()
            .child(filePath);
        
        print("🔍 WebAudioProcessing: Getting download URL from Firebase Storage...");
        final downloadUrl = await ref.getDownloadURL();
        print("🔍 WebAudioProcessing: Download URL obtained: $downloadUrl");
        return downloadUrl;
      } else {
        print("🔍 WebAudioProcessing: ERROR - Invalid GS URI format: $audioGSUri");
        throw Exception('Invalid GS URI: $audioGSUri');
      }
    } catch (e, stackTrace) {
      print("🔍 WebAudioProcessing: ERROR in _getDownloadUrlFromGSUri: $e");
      print("🔍 WebAudioProcessing: STACK TRACE: $stackTrace");
      rethrow;
    }
  }
  
  /// Generate a mock spectrogram for demonstration
  /// In a real implementation, you'd use Web Audio API for actual audio analysis
  static List<Float64List> _generateMockSpectrogram() {
    print("🔍 WebAudioProcessing: _generateMockSpectrogram() called");
    
    try {
      // Create a more realistic mock spectrogram that looks like a bird call
      final List<Float64List> spectrogramData = [];
      
      // Create a spectrogram that resembles a bird call pattern
      for (int timeFrame = 0; timeFrame < 150; timeFrame++) {
        final Float64List frame = Float64List(128); // More frequency bins
        
        // Generate bird-like call patterns
        for (int freqBin = 0; freqBin < 128; freqBin++) {
          double intensity = 0.0;
          
          // Create some harmonic structures typical of bird calls
          if (timeFrame > 20 && timeFrame < 130) {
            // Fundamental frequency around bin 30-50
            if (freqBin >= 30 && freqBin <= 50) {
              // Create a frequency sweep (bird call characteristic)
              double sweepPos = 30 + (timeFrame - 20) / 110.0 * 20;
              if (freqBin >= sweepPos - 3 && freqBin <= sweepPos + 3) {
                intensity = 0.8 - (freqBin - sweepPos).abs() / 3.0 * 0.4;
              }
            }
            
            // Second harmonic
            if (freqBin >= 60 && freqBin <= 100) {
              double sweepPos = 60 + (timeFrame - 20) / 110.0 * 40;
              if (freqBin >= sweepPos - 2 && freqBin <= sweepPos + 2) {
                intensity = math.max(intensity, 0.5 - (freqBin - sweepPos).abs() / 2.0 * 0.3);
              }
            }
            
            // Add some background noise
            intensity += (math.sin(timeFrame * 0.1 + freqBin * 0.05) + 1) * 0.05;
          } else {
            // Background noise only
            intensity = (math.sin(timeFrame * 0.2 + freqBin * 0.1) + 1) * 0.02;
          }
          
          frame[freqBin] = math.max(0.0, math.min(1.0, intensity));
        }
        spectrogramData.add(frame);
      }
      
      print("🔍 WebAudioProcessing: Mock bird-call spectrogram generated with ${spectrogramData.length} frames and ${spectrogramData[0].length} frequency bins");
      return spectrogramData;
    } catch (e, stackTrace) {
      print("🔍 WebAudioProcessing: ERROR in _generateMockSpectrogram: $e");
      print("🔍 WebAudioProcessing: STACK TRACE: $stackTrace");
      rethrow;
    }
  }
}
