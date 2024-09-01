import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:csv/csv.dart';

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
  Uint8List? _csvData;

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

      // Convert CSV string to bytes
      _csvData = Uint8List.fromList(csv.codeUnits);

      setState(() {
        _isPreparingDownload = false;
        _isDownloadReady = true;
        _downloadStatus = 'Download is ready';
      });
    } catch (e) {
      setState(() {
        _isPreparingDownload = false;
        _downloadStatus = 'Failed to prepare download: $e';
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_csvData != null) {
      try {
        await FileSaver.instance.saveFile(
          // add the current time to the file name in text like this: 'verifications_2022-01-01T12:00:00.csv' including the time
          name:
              'verifications_${DateTime.now().toIso8601String().replaceAll(':', '-')}',
          bytes: _csvData!,
          ext: "csv",
        );
        setState(() {
          _downloadStatus = 'CSV file downloaded successfully!';
        });
      } catch (e) {
        setState(() {
          _downloadStatus = 'Failed to download CSV file: $e';
        });
      }
    } else {
      setState(() {
        _downloadStatus = 'CSV data is null!';
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
