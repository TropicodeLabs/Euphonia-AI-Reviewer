import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'common_drawer.dart';

class UploadDataScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const UploadDataScreen({Key? key, required this.project}) : super(key: key);

  @override
  _UploadDataScreenState createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  List<PlatformFile>? _selectedFiles;
  bool _isUploading = false;
  String _uploadStatus = '';
  double _uploadProgress = 0;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      print("No files selected.");
      return;
    }

    // Validate files
    for (var file in _selectedFiles!) {
      try {
        // Check if file size is less than 5MB
        if (file.size > 5 * 1024 * 1024) {
          throw Exception('File ${file.name} exceeds the max filesize of 5MB.');
        }

        // Extract and validate filename data
        extractDataFromFilename(
            file.name); // lets receive and print the extracted data
        final data = extractDataFromFilename(file.name);
        print(data);
      } catch (e) {
        print("Validation failed for file ${file.name}: $e");
        setState(() {
          _uploadStatus = 'Validation failed for file ${file.name}: $e';
        });
        return;
      }
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });

    try {
      // Create a list of upload tasks
      List<Future> uploadTasks = [];

      for (var file in _selectedFiles!) {
        if (file.bytes != null) {
          uploadTasks.add(_uploadFile(file.bytes!, file.name));
        }
      }

      // Wait for all tasks to complete
      await Future.wait(uploadTasks);

      setState(() {
        _uploadStatus = 'Upload successful';
      });
    } catch (e) {
      print("Upload failed: $e");
      setState(() {
        _uploadStatus = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadFile(Uint8List fileBytes, String fileName) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('uploads/${widget.project['id']}/$fileName');
    // 'projects/${widget.project['id']}/cache/cachedBatchUploads/$fileName'; originalmente era aca

    UploadTask uploadTask = storageRef.putData(fileBytes);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    await uploadTask.whenComplete(() {
      print("File uploaded: $fileName");
    }).catchError((e) {
      print("Failed to upload file: $fileName, Error: $e");
      throw e;
    });
  }

  Map<String, String> extractDataFromFilename(String filename) {
    RegExp regExp = RegExp(r'([^_]+)_([^_]+)_(.*)_([^_]+s)_([^_]+s)\.wav');
    RegExpMatch? match = regExp.firstMatch(filename);

    if (match != null) {
      // get float numbers for startTime and endTime, if it fails it will throw an exception
      // these are strings like this  9.0s, endTime: 12.0s, so we have to remove the 's' and parse it to double

      // this will be a string that we will send to the server, so we need it as a string
      final startTime = match.group(4)!.replaceAll('s', '');
      final endTime = match.group(5)!.replaceAll('s', '');

      // validate that these values are numbers: confidence, segmentCount, startTime, endTime
      try {
        double.parse(match.group(1)!);
        double.parse(match.group(2)!);
        double.parse(startTime);
        double.parse(endTime);
      } catch (e) {
        throw FormatException('Filename does not match the expected pattern.');
      }

      return {
        'confidenceLevel': match.group(1)!,
        'segmentCount': match.group(2)!,
        'parentAudioName': match.group(3)!,
        'startTime': startTime,
        'endTime': endTime,
      };
    } else {
      throw FormatException('Filename does not match the expected pattern.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['title'] as String),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFiles,
              child: Text('Select WAV Files'),
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadFiles,
              child: Text('Upload Files'),
            ),
            Text(_uploadStatus),
            if (_selectedFiles != null && _selectedFiles!.isNotEmpty)
              ..._selectedFiles!.map((file) => Text(file.name)).toList(),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(value: _uploadProgress),
              ),
          ],
        ),
      ),
    );
  }
}
