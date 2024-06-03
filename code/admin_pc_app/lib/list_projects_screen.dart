import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_utils.dart';
import 'create_project_screen.dart';

class ListProjectsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> projects;

  const ListProjectsScreen({super.key, required this.projects});

  @override
  State<ListProjectsScreen> createState() => _ListProjectsScreenState();
}

class _ListProjectsScreenState extends State<ListProjectsScreen> {
  late List<Map<String, dynamic>> projects;

  final imgAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    projects = widget.projects; // Assign 'projects' in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your projects'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              FirebaseUtils.logout(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return buildProjectItem(projects[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the CreateProjectScreen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateProjectScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Project',
      ),
    );
  }

  Widget buildProjectItem(Map<String, dynamic> project) {
    return Card(
      clipBehavior:
          Clip.antiAlias, // Ensures the image is clipped to the card shape
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/data_dashboard_screen',
            arguments: project,
          );
        },
        child: IntrinsicHeight(
          // Ensures the row's children share the same height
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // Stretch row items to fit the card's height
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Align content to the start vertically
                    children: [
                      Text(
                        project['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(project['description']),
                    ],
                  ),
                ),
              ),
              Container(
                width: 200.0 * imgAspectRatio,
                height: 200.0,
                child: _getProjectImage(
                    project), // This will display the image on the right
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getProjectImage(Map<String, dynamic> project) {
    final String? imagePathBasename = project['imagePathBasename'];
    final String? imageUrl = project['imageUrl'];

    // Check if imagePathBasename is 'default', null, or if imageUrl is null or empty
    if (imagePathBasename == 'default' ||
        imagePathBasename == null ||
        imageUrl == null ||
        imageUrl.isEmpty) {
      // Return an empty Container (or SizedBox) when no image should be displayed
      print('No image to display for project: ${project['title']}');
      return SizedBox.shrink(); // This takes up no space
    }

    // If there's a valid imageUrl, proceed to render the image
    const double imageHeight = 200.0; // Fixed height for the image
    double imageWidth =
        200.0 * imgAspectRatio; // Calculate width based on the aspect ratio

    return ClipRect(
      child: Container(
        color: Colors
            .grey, // Background color in case the image doesn't fill the area
        height: imageHeight,
        width: imageWidth,
        child: Image.network(
          imageUrl,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            print('Error loading image: $error');
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            );
          },
          fit: BoxFit.fitHeight, // Adjust the fit as needed
        ),
      ),
    );
  }
}
