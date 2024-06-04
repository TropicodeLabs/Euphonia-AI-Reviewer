import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'utils.dart';

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
import 'dart:typed_data';

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
