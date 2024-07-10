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

class UploadDataScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const UploadDataScreen({Key? key, required this.project}) : super(key: key);

  @override
  _UploadDataScreenState createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  String? _clipInfoFilePath;
  String? _clipsDirectoryPath;
  bool _isUploading = false;
  String _uploadStatus = '';
  String _validationStatus = '';
  bool _isValidatedSuccessfully = false;
  List<List<dynamic>> _rows = [];
  List<ClipData> _clipsToUpload = [];
  List<FileSystemEntity> _absolutePathsOfFilesToUpload = [];
  ValidationSummary? _validationSummary;
  String _uploadProgress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['title'] as String),
      ),
      drawer: CommonDrawer(project: widget.project),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment
                  .center, // Align items vertically to the center
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Align items horizontally to the center
              children: [
                Text(
                  'Upload Project Data',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 20),
                Text(
                  'Select the clip information CSV file that contains metadata about the clips you wish to upload.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickClipInfoFile(),
                  child: Text('Select Clip Information CSV'),
                ),
                SizedBox(height: 8),
                Text(_clipInfoFilePath ?? 'No file selected',
                    textAlign: TextAlign.center),
                SizedBox(height: 20),
                Text(
                  'Select the directory containing the clips referenced in the CSV file.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickClipsDirectory(),
                  child: Text('Select Clips Directory'),
                ),
                SizedBox(height: 8),
                Text(_clipsDirectoryPath ?? 'No directory selected',
                    textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_clipInfoFilePath != null &&
                          _clipsDirectoryPath != null &&
                          !_isUploading)
                      ? () => _startDataValidation()
                      : null,
                  child: Text('Validate upload'),
                ),
                SizedBox(height: 16),
                Text(
                  _validationStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _validationStatus.toLowerCase().contains('error')
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                //HERE LETS RENDER THE INFO BOX
                // Inside the build method, after the _validationStatus Text widget
                if (_isValidatedSuccessfully && _validationSummary != null)
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildValidationSummaryWidgets(
                              _validationSummary!),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            _uploadData, // Placeholder function for upload logic
                        child: Text('Upload Data'),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _uploadStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _uploadStatus.toLowerCase().contains('error')
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // Build your UI here, similar to what you have in ManageProjectScreen
  }

  // Include all the methods related to file picking, validation, and uploading
  // Basically, you'll move methods like _pickClipInfoFile, _pickClipsDirectory,
  // _startDataValidation, _validateData, _uploadData, etc., from your existing
  // ManageProjectScreen class to here.

  Future<void> _pickClipInfoFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _clipInfoFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _pickClipsDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _clipsDirectoryPath = result;
      });
    }
  }

  Future<void> _startDataValidation() async {
    final validationSuccess = await _validateData();
    if (validationSuccess) {
      setState(() {
        _isValidatedSuccessfully = true;
        // Assuming _validateData method updates _validationSummary appropriately
      });
    } else {
      setState(() {
        _isValidatedSuccessfully = false;
        _validationSummary =
            null; // Clear previous summary if validation failed
      });
    }
  }

  Future<bool> _validateData() async {
    _updateValidationStatus('Validating...');
    if (!_areFilesSelected()) {
      return false;
    }

    _rows = [];
    try {
      _rows = await _readCsvFile();
      _clipsToUpload = _getClipDataListFromCsvRows(_rows);
    } catch (e) {
      _updateValidationStatus(
          'Error: CSV format is incorrect. ${e.toString()}');
      print(e);
      return false;
    }

    if (_rows.isEmpty) {
      // This check ensures rows is not null and not empty
      return false;
    }

    Set<String> csvBasenames = _extractCsvBasenames(_rows);
    if (csvBasenames.isEmpty) {
      return false;
    }

    // Assuming _listWavFilesInDirectory only returns files that are in csvBasenames
    _absolutePathsOfFilesToUpload =
        await _listWavFilesInDirectory(csvBasenames);
    if (_absolutePathsOfFilesToUpload.isEmpty) {
      _updateValidationStatus('No WAV files found in the selected directory.');
      return false;
    }

    // Assuming _checkForMissingAndIgnoredBasenames returns a boolean
    // indicating whether the check passed and also updates the UI with relevant messages
    bool checkPassed =
        _checkForMissingBasenames(csvBasenames, _absolutePathsOfFilesToUpload);
    if (!checkPassed) {
      return false;
    }

    // Calculate ignored basenames for passing to _validateFiles
    Set<String> allBasenames = _absolutePathsOfFilesToUpload
        .map((file) => path.basename(file.path))
        .toSet();
    Set<String> ignoredBasenames = allBasenames.difference(csvBasenames);

    // Now calling _validateFiles with both required arguments
    _validationSummary =
        await _validateFiles(_absolutePathsOfFilesToUpload, ignoredBasenames);
    if (_validationSummary == null) {
      _updateValidationStatus('Error: Failed to validate files.');
      return false;
    }

    // If you reach here, it means validation passed successfully
    _updateValidationStatus('Validation successful. Ready to upload.');
    return true;
  }

  void _updateValidationStatus(String message) {
    setState(() {
      _validationStatus = message;
    });
  }

  bool _areFilesSelected() {
    if (_clipInfoFilePath == null || _clipsDirectoryPath == null) {
      _updateValidationStatus(
          'Error: Both a clip information file and a clips directory must be selected.');
      return false;
    }
    return true;
  }

  Future<List<List<dynamic>>> _readCsvFile() async {
    // quizas quitarle
    final File csvFile = File(_clipInfoFilePath!);
    String csvContent = await csvFile.readAsString();
    return Utils.convertCsvStringToListOfLists(
        csvContent); // Ensure this method name is correct.
  }

  Set<String> _extractCsvBasenames(List<List<dynamic>> rows) {
    //  first case, it is empty
    if (rows.isEmpty) {
      _updateValidationStatus('Error: invalid CSV.');
      return {};
    }
    // second case, it does not contain the clip_basename
    if (!rows.first.contains('clip_basename')) {
      _updateValidationStatus(
          'Error: CSV format is incorrect. The first row must contain a column named "clip_basename".');
      return {};
    }
    return rows
        .skip(1)
        .map((row) => row[rows.first.indexOf('clip_basename')].toString())
        .toSet();
  }

  Future<List<FileSystemEntity>> _listWavFilesInDirectory(
      Set<String> csvBasenames) async {
    final dir = Directory(_clipsDirectoryPath!);
    List<FileSystemEntity> wavFilesInDir = await dir
        .list()
        .where((file) => path.extension(file.path).toLowerCase() == '.wav')
        .toList();
    return wavFilesInDir
        .where((file) => csvBasenames.contains(path.basename(file.path)))
        .toList();
  }

  bool _checkForMissingBasenames(
      Set<String> csvBasenames, List<FileSystemEntity> files) {
    final Set<String> fileBasenames =
        files.map((file) => path.basename(file.path)).toSet();
    final Set<String> missingBasenames = csvBasenames.difference(fileBasenames);

    if (missingBasenames.isNotEmpty) {
      _updateValidationStatus(
          'Error: Missing basenames in directory: ${missingBasenames.join(", ")}.');
      return false;
    }

    return true;
  }

  Future<ValidationSummary?> _validateFiles(
      List<FileSystemEntity> files, Set<String> ignoredBasenames) async {
    if (files.isEmpty) return null;

    List<double> durations = [];
    List<double> fileSizes = [];

    for (FileSystemEntity file in files) {
      File wavFile = File(file.path);
      double durationInSeconds = await _getWavDuration(wavFile);
      durations.add(durationInSeconds);

      int fileSize = await wavFile.length();
      fileSizes.add(fileSize.toDouble());
    }

    double meanFileSize = fileSizes.reduce((a, b) => a + b) / fileSizes.length;
    double minFileSize = fileSizes.reduce(min);
    double maxFileSize = fileSizes.reduce(max);

    double meanDuration = durations.reduce((a, b) => a + b) / durations.length;
    double minDuration = durations.reduce(min);
    double maxDuration = durations.reduce(max);

    return ValidationSummary(
      totalFiles: files.length,
      meanFileSize: _formatBytes(meanFileSize),
      minFileSize: _formatBytes(minFileSize),
      maxFileSize: _formatBytes(maxFileSize),
      meanDuration: meanDuration,
      minDuration: minDuration,
      maxDuration: maxDuration,
      ignoredFiles: ignoredBasenames.toList(),
    );
  }

  String _formatBytes(double bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 Bytes";
    const suffixes = ["Bytes", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void _showValidationSummary() {
    if (_validationSummary == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validation Summary'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Total Files: ${_validationSummary!.totalFiles}'),
                Text('Mean File Size: ${_validationSummary!.meanFileSize}'),
                Text(
                    'Min/Max File Size: ${_validationSummary!.minFileSize} / ${_validationSummary!.maxFileSize}'),
                Text(
                    'Mean Duration: ${_validationSummary!.meanDuration.toStringAsFixed(2)}s'),
                Text(
                    'Min/Max Duration: ${_validationSummary!.minDuration.toStringAsFixed(2)}s / ${_validationSummary!.maxDuration.toStringAsFixed(2)}s'),
                if (_validationSummary!.ignoredFiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        'Ignored Files: \n${_validationSummary!.ignoredFiles.join('\n')}'),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ////////////////////////////////////////////////////////  REFORMATTING

  Future<double> _getWavDuration(File wavFile) async {
    // Calculate duration of the .wav file
    // get source from absolute path
    String absolutePath = wavFile.absolute.path;
    // print(absolutePath);
    final audioPlayer = AudioPlayer();
    try {
      final duration = await audioPlayer.setFilePath(absolutePath);

      if (duration == null) {
        throw Exception('Failed to get duration of file ${wavFile.path}');
      }
      double durationInSeconds = duration.inSeconds.toDouble();
      // print('Duration in seconds: $durationInSeconds' +
      //     ' for file ' +
      //     wavFile.path);

      await audioPlayer.dispose();
      return durationInSeconds;
    } catch (e) {
      await audioPlayer.dispose();
      throw Exception('Failed to get duration of file ${wavFile.path}: $e');
    }
  }

  List<Widget> _buildValidationSummaryWidgets(ValidationSummary summary) {
    return [
      Text('Validation Summary:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      Text('• Total Files: ${summary.totalFiles}'),
      Text('• Mean File Size: ${summary.meanFileSize}'),
      Text(
          '• File Size Range: ${summary.minFileSize} - ${summary.maxFileSize}'),
      Text(
          '• Mean Duration: ${summary.meanDuration.toStringAsFixed(2)} seconds'),
      Text(
          '• Duration Range: ${summary.minDuration.toStringAsFixed(2)} - ${summary.maxDuration.toStringAsFixed(2)} seconds'),
      if (summary.ignoredFiles.isNotEmpty)
        Text('• Ignored Files: \n  - ${summary.ignoredFiles.join('\n  - ')}'),
    ];
  }

  void _uploadData() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });

    /// A. upload wav files by first compressing batches of 500 files //////////////////
    /// and then uploading them to the project's firebase storage cached folder
    /// which will be used by a cloud function that i will have to call from here
    /// to uncompress it and move it to the final folder
    try {
      for (var i = 0; i < _absolutePathsOfFilesToUpload.length; i += 500) {
        var batch = _absolutePathsOfFilesToUpload.sublist(
            i, min(i + 500, _absolutePathsOfFilesToUpload.length));
        String pathOfBatchInTmpLocalPath = '';
        String firebaseStorageCompressedFilePath = '';

        //0.0 TODO: check if the files are already in the desired project's firebase storage path
        // probably through a cloud function that will receive a list of max length 500

        // 0.1 Compress the batch of wav files
        // into a temporary directory
        // later we will clean this directory
        try {
          pathOfBatchInTmpLocalPath = await _compressBatchOfWavFiles(batch);
        } catch (e) {
          print('Compression error: $e');
          setState(() {
            _uploadStatus = 'Compression Error: $e';
          });
          return;
        }

        // 1. Upload the batch to the project's firebase storage cached folder
        try {
          firebaseStorageCompressedFilePath =
              await _uploadBatchOfWavFilesToCachedFolder(
                  pathOfBatchInTmpLocalPath, batch);
        } catch (e) {
          print('Upload error: $e');
          setState(() {
            _uploadStatus = 'Upload Error: $e';
          });
          // delete compressed file from local storage. It handles its own errors
          await _cleanTmpDirectory(pathOfBatchInTmpLocalPath);
          return;
        }

        //2. Clean the temporary directory. It handles its own errors
        await _cleanTmpDirectory(pathOfBatchInTmpLocalPath);

        // 3. Prepare data to add to Firestore throught the cloud function call
        List<Map<String, dynamic>> batchClipData = _subsetClipsToUpload(batch);
        // for debugging lets print its lenght and the first element
        print('Batch clip data lenght: ${batchClipData.length}');

        print('First element: ${batchClipData.first}');

        // 3.5 Write batchClipData to firestore, in the processId document
        // let's start by getting an id for the process
        String processDocId = FirebaseFirestore.instance
            .collection(
                'AudioProcessingTasks/${widget.project['id']}/UploadTasks')
            .doc()
            .id;
        print("Process doc id: $processDocId");
        // then we write the batchClipData to the firestore
        try {
          await _saveBatchClipDataToFirestoreInBatches(
              batchClipData, processDocId);
        } catch (e) {
          print('Firestore error: $e');
          setState(() {
            _uploadStatus = 'Firestore Error: $e';
          });
          return;
        }

        // 4. Call the cloud function to uncompress the batch
        try {
          bool success =
              await _callCloudFunctionToUncompressBatchAndSaveDataToFirestore(
                  firebaseStorageCompressedFilePath, processDocId);
          if (!success) {
            throw Exception('Failed to trigger cloud function.');
          }
          print('Process doc id: $processDocId');
          _listenToUploadProcess(processDocId);
          // now we should listen to the processDocId to know when the process is done
          // by checking the firestore document located at `AudioProcessingTasks/${projectId}/UploadTasks/${processId}`
          // lets define the listener function and call it here, it should update the ui with the progress
          // and the message of the process; those fields are called exactly: progress and message
          // we should also check if the process is done and if it is done we should update the ui with the result
          // and if it is an error we should update the ui with the error message

          // 5. Listen to the processDocId to know when the process is done. the return value will be a stream
// TODO: write function and call it here
          // 6. Update the UI with the result or error message
          // for these tasks to be performed we can use this object initialized in class scope
          // _uploadProgress, but we could also use a streambuilder idk
        } catch (e) {
          print('Cloud function error: $e');
          setState(() {
            _uploadStatus = 'Cloud Function Error: $e';
          });
          return;
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _uploadStatus = 'Error: $e';
      });
      return;
    }
  }

  List<Map<String, dynamic>> _subsetClipsToUpload(
      List<FileSystemEntity> batch) {
    //  Create a subset of ClipData objects that correspond to the batch
    // of files being uploaded. It is a subset of
    List<ClipData> subset = _clipsToUpload
        .where((clip) => batch
            .map((file) => path.basename(file.path))
            .contains(clip.clipBasename))
        .toList();
    // Convert each ClipData object in the subset to a Map
    return subset.map((clip) => clip.toMap()).toList();
  }

  void _listenToUploadProcess(String processDocId) {
    // Assuming `projectId` is available in your class
    String path =
        'AudioProcessingTasks/${widget.project['id']}/UploadTasks/$processDocId';
    var documentReference = FirebaseFirestore.instance.doc(path);

    documentReference.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        setState(() {
          // Assuming you have a method or logic to update your UI based on the data
          _uploadStatus =
              'Progress: ${data?['percentage']}%\n${data?['message']}';
        });

        // Check if the process is done and update UI accordingly
        if (data?['done'] == true) {
          // Update UI to show completion or handle errors
          if (data?['error'] != null) {
            _uploadStatus = 'Error: ${data?['error']}';
          } else {
            _uploadStatus = 'Upload completed successfully.';
          }
        }
      }
    }, onError: (error) {
      // Handle any errors that occur during listening
      print("Error listening to upload process: $error");
      setState(() {
        _uploadStatus = 'Listening Error: $error';
      });
    });
  }

// _saveBatchClipDataToFirestoreInBatches
  Future<void> _saveBatchClipDataToFirestoreInBatches(
      List<Map<String, dynamic>> batchClipData, String processDocId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    const int batchSize =
        250; // Adjust based on your data size and Firestore limits

    List<List<Map<String, dynamic>>> batches = [];
    for (int i = 0; i < batchClipData.length; i += batchSize) {
      batches.add(batchClipData.sublist(
          i,
          i + batchSize > batchClipData.length
              ? batchClipData.length
              : i + batchSize));
    }

    // Process each batch
    for (var batch in batches) {
      // Start a new batch
      WriteBatch writeBatch = db.batch();

      // Assuming you have a collection for each batch under the process ID
      String batchCollectionPath =
          'AudioProcessingTasks/${widget.project['id']}/UploadTasks/$processDocId/batches';
      for (var clipData in batch) {
        DocumentReference docRef = db
            .collection(batchCollectionPath)
            .doc(); // Let Firestore generate the doc ID
        writeBatch.set(docRef, clipData);
      }

      // Commit the batch
      await writeBatch.commit().catchError((error) {
        print("Error writing batch to Firestore: $error");
      });
    }

    // print the path of the firestore batches

    print('Firestore batches path: ');
    print(
        'AudioProcessingTasks/${widget.project['id']}/UploadTasks/$processDocId/batches');
  }

  Future<bool> _callCloudFunctionToUncompressBatchAndSaveDataToFirestore(
    String filePath,
    String processId,
  ) async {
    try {
      FirebaseFunctions functions = FirebaseFunctions.instance;

      HttpsCallable callable = functions.httpsCallable('processAudioUpload');

      // Call the function and pass parameters as needed
      final results = await callable.call({
        'projectId': widget.project['id'],
        'processId': processId,
        'filePath': filePath,
      }).timeout(Duration(seconds: 500));

      // Process results if needed
      print("Function call succeeded: ${results.data}");
      // backend does this   return { processDocId: processDocRef.id }
      // so we shall return the processDocId
      return results.data['result'];
    } catch (e) {
      print("Failed to call function: $e");
      throw Exception('Failed to trigger cloud function: $e');
    }
  }

  Future<void> _cleanTmpDirectory(String filePath) async {
    final File file = File(filePath);

    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        print('Error deleting file: $e');
        setState(() {
          _uploadStatus = 'Error deleting file: $e';
        });
      }
    }
  }

  Future<String> _uploadBatchOfWavFilesToCachedFolder(
      String filePath, List<FileSystemEntity> batch) async {
    final File file = File(filePath);
    final String fileName = path.basename(filePath);
    final String firebaseStoragePath =
        'projects/${widget.project['id']}/cache/cachedBatchUploads/$fileName';
    final ref = FirebaseStorage.instance.ref(firebaseStoragePath);

    var task = ref.putFile(file);
    task.snapshotEvents.listen((event) {
      print('Uploading... ${event.bytesTransferred}/${event.totalBytes}');
      // TODO: Update the UI with the upload progress
    });
    await task;
    return firebaseStoragePath;
  }

  Future<String> _compressBatchOfWavFiles(List<FileSystemEntity> files) async {
    // Create a new archive
    final archive = Archive();

    for (final file in files) {
      final File fileToCompress = File(file.path);
      final List<int> bytes = await fileToCompress.readAsBytes();
      final archiveFile =
          ArchiveFile(path.basename(file.path), bytes.length, bytes);
      archive.addFile(archiveFile);
    }

    // Encode the archive
    final zipData = ZipEncoder().encode(archive);
    final tempDir = await getTemporaryDirectory();
    final compressedFile = File(
        //timestamp without special characters
        '${tempDir.path}/batch_timestamp_${DateTime.now().millisecondsSinceEpoch}.zip');
    if (zipData != null) {
      await compressedFile.writeAsBytes(zipData);
    } else {
      // Handle the unexpected null case appropriately
      throw Exception('Failed to compress files.');
    }
    print('Compressed file: ${compressedFile.path}');
    return compressedFile.path;
  }

  List<ClipData> _getClipDataListFromCsvRows(List<List<dynamic>> rows) {
    if (rows.isEmpty || rows.first.isEmpty) {
      _updateValidationStatus('Error: CSV is empty or missing headers.');
      throw Exception('CSV is empty or missing headers.');
    }

    // Assuming the first row contains headers
    List<String> headers = rows.first.map((e) => e.toString()).toList();
    List<ClipData> clips = [];

    // Skip the header row and iterate over each data row
    for (var row in rows.skip(1)) {
      Map<String, dynamic> rowData = {};
      for (int i = 0; i < headers.length; i++) {
        // Map each column to its corresponding value in the row
        rowData[headers[i]] = i < row.length ? row[i] : null;
      }
      print("here");
      // Create a ClipData object from rowData
      ClipData clip = ClipData(
        selection: _toInt(rowData['Selection']),
        beginFile: _toString(rowData['Begin File']),
        beginTime: _toDouble(rowData['Begin Time (s)']),
        endTime: _toDouble(rowData['End Time (s)']),
        lowFreq: _toDouble(rowData['Low Freq (Hz)']),
        highFreq: _toDouble(rowData['High Freq (Hz)']),
        speciesCode: _toString(rowData['Species Code']) ?? '',
        commonName: _toString(rowData['Common Name']) ?? '',
        confidence: _toDouble(rowData['Confidence']) ?? 0.0,
        clipBasename: _toString(rowData['clip_basename']) ?? '',
      );

      clips.add(clip);
    }

    return clips;
  }

  String? _toString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  void _validateClipData(ClipData clip) {
    if (clip.beginTime == null || clip.endTime == null) {
      throw Exception('Clip data is missing beginTime or endTime.');
    }
    if (clip.lowFreq == null || clip.highFreq == null) {
      throw Exception('Clip data is missing lowFreq or highFreq.');
    }
    if (clip.speciesCode.isEmpty || clip.commonName.isEmpty) {
      throw Exception('Clip data is missing speciesCode or commonName.');
    }
    if (clip.confidence < 0 || clip.confidence > 1) {
      throw Exception('Clip data has an invalid confidence value.');
    }
    if (clip.clipBasename.isEmpty) {
      throw Exception('Clip data is missing clipBasename.');
    }
    if (!widget.project['labels']['speciesCodes'].contains(clip.speciesCode)) {
      throw Exception(
          'Clip data has an invalid speciesCode: ${clip.speciesCode}');
    }
    if (!widget.project['labels']['commonNames'].contains(clip.commonName)) {
      throw Exception(
          'Clip data has an invalid commonName: ${clip.commonName}');
    }
  }
}

class ValidationSummary {
  final int totalFiles;
  final String meanFileSize;
  final String minFileSize;
  final String maxFileSize;
  final double meanDuration;
  final double minDuration;
  final double maxDuration;
  final List<String> ignoredFiles;

  ValidationSummary({
    required this.totalFiles,
    required this.meanFileSize,
    required this.minFileSize,
    required this.maxFileSize,
    required this.meanDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.ignoredFiles,
  });
}
// "Selection": "selection",
// "Begin File": "beginFile",
// "Begin Time (s)": "beginTime",
// "End Time (s)": "endTime",
// "Low Freq (Hz)": "lowFreq",
// "High Freq (Hz)": "highFreq",
// "Species Code": "speciesCode",
// "Common Name": "commonName",
// "Confidence": "confidence",
// "clip_basename": "clipBasename",

class ClipData {
  //not mandatory
  final int? selection;
  final String? beginFile;
  final double? beginTime;
  final double? endTime;
  final double? lowFreq;
  final double? highFreq;
//mandatory
  final String speciesCode;
  final String commonName;
  final double confidence;
  final String clipBasename;

  ClipData({
    this.selection,
    this.beginFile,
    this.beginTime,
    this.endTime,
    this.lowFreq,
    this.highFreq,
    required this.speciesCode,
    required this.commonName,
    required this.confidence,
    required this.clipBasename,
  });

  Map<String, dynamic> toMap() {
    return {
      'selection': selection,
      'beginFile': beginFile,
      'beginTime': beginTime,
      'endTime': endTime,
      'lowFreq': lowFreq,
      'highFreq': highFreq,
      'speciesCode': speciesCode,
      'commonName': commonName,
      'confidence': confidence,
      'clipBasename': clipBasename,
    };

    // create from map that may not have all fields, will fill the rest with null
  }
}
