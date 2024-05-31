import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DownloadDataScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const DownloadDataScreen({Key? key, required this.project}) : super(key: key);

  @override
  _DownloadDataScreenState createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  bool _isPreparingDownload = false;
  bool _isDownloadReady = false;
  String _downloadStatus = 'Ready to prepare download';
  String? _zipGSUri;
  String _messages = "";

  Future<void> _startDownloadProcess() async {
    setState(() {
      _isPreparingDownload = true;
      _downloadStatus = 'Preparing download...';
    });

    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('processAudioDownload');
    try {
      final result = await callable.call({'projectId': widget.project['id']});
      print("Download process started: ${result.data['processDocId']}");
      _listenToDownloadProcess(result.data['processDocId']);
    } catch (e) {
      setState(() {
        _isPreparingDownload = false;
        _downloadStatus = 'Failed to prepare download: $e';
      });
    }
  }

  void _listenToDownloadProcess(String processDocId) {
    final processDocRef = FirebaseFirestore.instance
        .collection(
            'AudioProcessingTasks/${widget.project['id']}/DownloadTasks')
        .doc(processDocId);

    processDocRef.snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          setState(() {
            _downloadStatus =
                'Download preparation progress: ${data?['percentage']}%';
            _messages = data?['messages'] ?? "";
          });

          if (data?['status'] == 'completed') {
            _zipGSUri = data?['zipGSUri'];
            _downloadStatus = 'Download ready. Tap to download.';
            _isPreparingDownload = false;
            _isDownloadReady = true;
          } else if (data?['status'] == 'failed') {
            _downloadStatus = 'Download failed: ${data?['message']}';
            _isPreparingDownload = false;
          }
        }
      },
      onError: (error) => setState(() {
        _downloadStatus = 'Error listening to download process: $error';
        _isPreparingDownload = false;
      }),
    );
  }

  Future<void> _downloadFile() async {
    if (_zipGSUri != null) {
      final String? selectedDirectory =
          await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        // Convert the GS URI to a reference
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child(_zipGSUri!);

        String basename = _zipGSUri!.split('/').last;

        print('zipGSUri: $_zipGSUri');

        print('Downloading file to $selectedDirectory/downloaded_file.zip');

        try {
          final bytes = await ref.getData();
          if (bytes != null) {
            File file = File('$selectedDirectory/$basename');
            await file.writeAsBytes(bytes);
            setState(() {
              _downloadStatus = 'File downloaded successfully to ${file.path}';
            });
          } else {
            setState(() {
              _downloadStatus = 'Failed to download file: File is empty';
            });
          }
        } catch (e) {
          print('Failed to download file: $e');
          if (e is FirebaseException) {
            print('Details: ${e.message}');
            setState(() {
              _downloadStatus = 'Failed to download file: ${e.message}';
            });
          } else {
            setState(() {
              _downloadStatus = 'Failed to download file: Unknown error';
            });
          }
        }
      } else {
        setState(() {
          _downloadStatus = 'Download cancelled.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Data'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isPreparingDownload)
                CircularProgressIndicator()
              else if (!_isDownloadReady)
                ElevatedButton(
                  onPressed: _startDownloadProcess,
                  child: Text('Prepare Download'),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_downloadStatus),
              ),
              Text(_messages),
              if (_isDownloadReady)
                ElevatedButton(
                  onPressed: _downloadFile,
                  child: Text('Start Download'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
