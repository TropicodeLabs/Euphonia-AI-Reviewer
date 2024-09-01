import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart'; // Add csv package in pubspec.yaml

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
  String _messages = "";
  String? _csvFilePath;

  Future<void> _startDownloadProcess() async {
    setState(() {
      _isPreparingDownload = true;
      _downloadStatus = 'Preparing download...';
    });

    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('processVerificationsDownload');
    try {
      final result = await callable.call({'projectId': widget.project['id']});
      final data = result.data['data'];

      // Parse the data to CSV
      List<List<dynamic>> rows = [];

      if (data.isNotEmpty) {
        // Add the headers
        rows.add(data[0].keys.toList());

        // Add the rows
        for (var row in data) {
          rows.add(row.values.toList());
        }
      }

      String csv = const ListToCsvConverter().convert(rows);

      // Save the CSV to a local file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/downloaded_data.csv';
      final file = File(path);
      await file.writeAsString(csv);

      setState(() {
        _isPreparingDownload = false;
        _isDownloadReady = true;
        _downloadStatus = 'Download is ready';
        _csvFilePath = path;
      });
    } catch (e) {
      setState(() {
        _isPreparingDownload = false;
        _downloadStatus = 'Failed to prepare download: $e';
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_csvFilePath != null) {
      final file = File(_csvFilePath!);

      // Check if file exists and proceed to share/download
      if (await file.exists()) {
        // Implement the logic for sharing or downloading the file.
        // For example, you can use a plugin like `share_plus` to share the file.
        // You can also use other methods depending on the platform to allow the user to save the file.
      } else {
        setState(() {
          _downloadStatus = 'CSV file does not exist!';
        });
      }
    } else {
      setState(() {
        _downloadStatus = 'CSV file path is null!';
      });
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
                  child: Text('Download CSV File'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
