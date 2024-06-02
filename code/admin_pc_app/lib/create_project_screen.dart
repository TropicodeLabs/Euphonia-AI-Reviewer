import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'list_projects_screen.dart';
import 'data_policy_screen.dart';
import 'firebase_utils.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _commonNames = [];
  List<String> _speciesCodes = [];
  String? _imagePath;
  bool _useDefaultImage = false;
  bool _isImageSelectedOrDefaultUsed =
      false; // Track if an image is selected or default is used
  bool _isCsvValid = false; // Track if the CSV is valid
  bool _isProjectPublic = false;
  bool _isLoading = false;

  final _storage = FirebaseStorage.instance;
  @override
  void initState() {
    super.initState();
    // Initialize your state variables if needed
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData:
          true, // Necessary to retrieve the image file for resolution check
    );

    if (result != null) {
      final fileBytes = result.files.first.bytes;
      final image = img.decodeImage(fileBytes!);
      if (image!.width == 1280 && image.height == 720) {
        setState(() {
          _imagePath = result.files.single.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image must be 1280x720 resolution.')),
        );
      }
    } else {
      // User canceled the picker
    }
    // Update the state to reflect if an image is selected or default is used
    if (_imagePath != null || _useDefaultImage) {
      setState(() {
        _isImageSelectedOrDefaultUsed =
            true; // Image is selected or default is used
      });
    } else {
      setState(() {
        _isImageSelectedOrDefaultUsed = false;
      });
    }
  }

  Widget buildImagePreview() {
    if (_imagePath == null) {
      return Text('No image selected.');
    } else {
      return Column(children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
        ),
        SizedBox(height: 20)
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Project'),
        // logout is possible here
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              FirebaseUtils.logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectInfoSection(),
              SizedBox(height: 40),
              _buildImageSection(),
              SizedBox(height: 40),
              _buildCsvSection(),
              SizedBox(height: 40),
              _projectPrivacySection(),
              SizedBox(height: 40),
              _buildSubmitButton(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Information',
            style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 8),
        _buildTextField(_titleController, 'Title', Icons.title),
        SizedBox(height: 16),
        _buildTextField(
            _descriptionController, 'Description', Icons.description),
      ],
    );
  }

  Widget _projectPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admission Policy',
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8), // Add some spacing
        Text(
          'By default, all projects are set to private to protect your data. However, if you choose to make your project public, it could significantly enhance your project\'s visibility and potentially attract more contributions and data from the community.',
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataPolicyScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'More Info',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text('Public Project'),
            Switch(
              value: _isProjectPublic,
              onChanged: (value) {
                setState(() {
                  _isProjectPublic = value;
                });
              },
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter a $label' : null,
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project cover', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 8),
        Text(
          'Please select an image with a resolution of 1280x720 pixels to display as the project cover.',
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Spacer(),
              ElevatedButton(
                onPressed: _useDefaultImage ? null : pickImage,
                child: Text('Pick an Image'),
              ),
              SizedBox(width: 16),
            ])),
            // Introducing a vertical divider in the middle
            Container(
              height: 20,
              child: VerticalDivider(color: Colors.grey),
            ),
            // Aligning checkbox to the very right with the text immediately next to it
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 16),
                  Text("Use default image"),
                  Checkbox(
                    value: _useDefaultImage,
                    onChanged: (bool? value) {
                      setState(() {
                        _useDefaultImage = value!;
                        _isImageSelectedOrDefaultUsed =
                            _useDefaultImage || _imagePath != null;
                        if (_useDefaultImage) {
                          _imagePath = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!_useDefaultImage && _imagePath != null) ...[
          SizedBox(height: 16),
          buildImagePreview(),
        ],
      ],
    );
  }

  Widget _buildCsvSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Species Names', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 8),
        Text(
            'Import a CSV file with these exact column names: "common name" and "species code". The CSV file should contain at least two rows.'),
        SizedBox(height: 8),
        Text('Example:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildCsvExampleTable([
          ['common name', 'species code'],
          ['Resplandescent Quetzal', 'Pharomachrus mocinno'],
          ['Three-wattled Bellbird', 'Procnias tricarunculatus'],
        ]),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.shade100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tip:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, height: 1.5),
                  children: [
                    TextSpan(
                        text:
                            'The "species code" can represent call types within a species, allowing for versatile project categorization. '),
                    TextSpan(text: 'In the app\'s display settings, '),
                    TextSpan(
                        text: '"species code" ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'is positioned directly below '),
                    TextSpan(
                        text: '"common name" ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'in a vertical layout, ensuring organized presentation of project data. '),
                    TextSpan(
                        text:
                            'Depending on user preference, both labels can be displayed if "both" is selected in the display name preferences. Alternatively, users may opt to display only one.'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text('Example of a custom csv file:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCsvExampleTable([
                ['common name', 'species code'],
                ['White-faced capuchin', 'twitter'],
                ['White-faced capuchin', 'lost call'],
              ]),
              // TODO: Add screenshot of how this example looks in the app
              // TODO: Add a link to a sample CSV file
            ],
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: pickAndParseCsv,
          child: Text('Import CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.background,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ),
        _buildCsvImportFeedback(), // Add this line to include the feedback widget
      ],
    );
  }

  Widget _buildCsvExampleTable(List<List<String>> data) {
    return Wrap(
      children: [
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
          },
          children: data.map((List<String> row) {
            return TableRow(
              children: row.map((String cell) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(cell),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed:
              (_isImageSelectedOrDefaultUsed && _isCsvValid && !_isLoading)
                  ? createProjectCloudFunction
                  : null,
          child: _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text('Create Project'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> pickAndParseCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return; // User canceled the picker

    String filePath = result.files.single.path!;
    String csvContent = await File(filePath).readAsString();

    // Normalize line endings to \n
    String normalizedContent =
        csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    List<String> lines = normalizedContent.split('\n');

    List<List<String>> fields = [];
    for (String line in lines) {
      if (line.isEmpty || !line.contains(',')) continue;
      List<String> row = line.split(',').map((cell) => cell.trim()).toList();
      fields.add(row);
    }

    print("Fields: $fields"); // devbug print
    // print field list length
    print(fields.length);

    if (!_isValidCsvFormat(fields)) {
      _showCsvError(
          "Wrong format. The CSV must contain 'common name' and 'species code' columns.");
      return;
    }

    List<String> commonNames = [];
    List<String> speciesCodes = [];
    for (var i = 1; i < fields.length; i++) {
      int commonNameIndex = fields[0].indexOf('common name');
      int speciesCodeIndex = fields[0].indexOf('species code');

      if (i > 10000) {
        _showCsvError("Cannot import more than ten thousand names.");
        return;
      }

      commonNames.add(fields[i][commonNameIndex]);
      speciesCodes.add(fields[i][speciesCodeIndex]);
    }

    if (!_validateCsvData(commonNames, speciesCodes)) {
      // Errors are handled within _validateCsvData
      return;
    }

    // If all validations pass, assign the data to the state variables
    setState(() {
      _commonNames = commonNames;
      _speciesCodes = speciesCodes;
      _isCsvValid = true; // CSV is valid
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV imported successfully!')),
    );
  }

  bool _isValidCsvFormat(List<List<dynamic>> fields) {
    // devbug prints
    // print(fields);
    // print(fields.isNotEmpty);
    // print(fields[0].contains('common name'));
    // print(fields[0].contains('species code'));
    // print(fields[0]);
    return fields.isNotEmpty &&
        fields[0].any(
            (header) => header.toString().toLowerCase() == 'common name') &&
        fields[0]
            .any((header) => header.toString().toLowerCase() == 'species code');
  }

  bool _validateCsvData(List<String> commonNames, List<String> speciesCodes) {
    if (commonNames.length < 2 || speciesCodes.length < 2) {
      _showCsvError(
          "Insufficient data: Both 'Common Names' and 'Species Codes' columns must contain at least two entries to ensure a valid comparison. If your project involves binary classification, please include an additional 'Background' row in your CSV file to meet this requirement.");
      return false;
    }

    if (commonNames.length != speciesCodes.length) {
      _showCsvError(
          "The number of common names must match the number of species codes.");
      return false;
    }

    if (commonNames.any((name) => name.length < 1) ||
        speciesCodes.any((code) => code.length < 1)) {
      _showCsvError(
          "Common names and species codes must be at least one character long.");
      return false;
    }

    return true;
  }

  void _showCsvError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _isCsvValid = false; // CSV is invalid
    });
  }

  Future<void> createProjectCloudFunction() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) {
      return; // Early return if form is not valid or if already loading
    }

    setState(() {
      _isLoading = true;
    });

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginError();
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? imagePathBasename = _getImagePathBasename();

    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('createProject');
    try {
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isActive':
            false, // By default all projects are inactive until the admin activates them manually
        'isPublic': _isProjectPublic,
        'imagePathBasename': imagePathBasename,
        'labels': {
          'commonName': _commonNames,
          'speciesCode': _speciesCodes,
        },
      });

      var projectData = result.data as Map<String, dynamic>;

      // upload data to firebase storage to the desired location: projects/{projectId}/description/{imagePathBasename}
      imagePathBasename = await _uploadImageIfNeeded(projectData['id']);

      // get all projects in which the user is an admin

      List<Map<String, dynamic>> projects =
          await FirebaseUtils.getProjects(user.uid);

      _navigateToListProjecstScreen(projects);
    } catch (e) {
      _showCreationError(e.toString());
      // navigate back if failed
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getImagePathBasename() {
    if (_imagePath == null) return 'default';
    return _imagePath!.split('/').last;
  }

  Future<String?> _uploadImageIfNeeded(String projectId) async {
    if (_imagePath == null) return null;

    String imagePathBasename = _imagePath!.split('/').last;
    String storagePath = 'projects/$projectId/description/$imagePathBasename';
    await _storage.ref(storagePath).putFile(File(_imagePath!));
    return imagePathBasename;
  }

  void _navigateToListProjecstScreen(List<Map<String, dynamic>> projects) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListProjectsScreen(
          projects: projects,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project created successfully!')),
    );
  }

  void _showLoginError() {
    print('User is not logged in.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You must be logged in to create a project.')),
    );
  }

  void _showCreationError(String error) {
    print(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create project.')),
    );
  }

  Widget _buildCsvImportFeedback() {
    if (!_isCsvValid || _commonNames.isEmpty || _speciesCodes.isEmpty) {
      return Container(); // Return an empty container if no CSV is imported or if it's invalid.
    }

    // Prepare strings to display the first and last three items
    String commonNamesPreview = _getPreviewText(_commonNames);
    String speciesCodesPreview = _getPreviewText(_speciesCodes);

    return Card(
      margin: EdgeInsets.only(top: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CSV Import Successful',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Common Names: $commonNamesPreview'),
            Text('Species Codes: $speciesCodesPreview'),
            Text('Total Entries: ${_commonNames.length}'),
          ],
        ),
      ),
    );
  }

  String _getPreviewText(List<String> list) {
    // Get first and last three items, handling lists shorter than 6
    int count = list.length;
    String preview = list.sublist(0, count < 3 ? count : 3).join(', ');
    if (count > 3) {
      preview += ' ... ';
      preview += list.sublist(count < 6 ? 3 : count - 3, count).join(', ');
    }
    return preview;
  }
}
