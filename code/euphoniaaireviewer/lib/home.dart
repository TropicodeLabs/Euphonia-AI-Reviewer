import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "example_behavior.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'firebase_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final imgAspectRatio = 16 / 9;

  bool _isAddingProject =
      false; // Track whether the add project UI should be shown
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Project'),
        actions: [
          // only logout
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              FirebaseUtils.logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isAddingProject) _buildAddProjectUI(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: FirebaseUtils.getProjects(
                  FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching projects.'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final projects = snapshot.data!;
                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return buildProjectItem(projects[index]);
                    },
                  );
                } else {
                  return const Center(child: Text('No projects found.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAddProjectUI,
        child: Icon(_isAddingProject ? Icons.close : Icons.add),
        tooltip: _isAddingProject ? 'Cancel' : 'Add Project',
      ),
    );
  }

  Future<void> _addProject() async {
    final password = _passwordController.text;
    if (password.isNotEmpty) {
      try {
        await FirebaseUtils.addProjectToUserList(password);
        // Optionally reset UI and show success message
        setState(() {
          _isAddingProject = false;
          _passwordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Project added successfully')));
        // //  should rebuild the UI to reflect the new project
        // // we can do this by calling setState
        // setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add project')));
      }
    }
  }

  void _toggleAddProjectUI() {
    setState(() {
      _isAddingProject = !_isAddingProject;
    });
  }

  Widget _buildAddProjectUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Project Password',
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _passwordController.clear(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _addProject(),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text('Add Project'),
          ),
        ],
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
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.fitHeight, // Adjust the fit as needed
        ),
      ),
    );
  }

  Widget buildProjectItem(Map<String, dynamic> project) {
    // Calculate the image height based on the full width of the device and the aspect ratio
    // Assuming imgAspectRatio is the aspect ratio of your image
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth /
        imgAspectRatio; // Compute the height based on the full width and aspect ratio

    return Card(
      clipBehavior:
          Clip.antiAlias, // Ensures the image is clipped to the card shape
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/example',
            arguments: project, // Pass the entire project map here
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container that takes the full width
            Container(
              width: screenWidth, // Use the full width of the device
              height: imageHeight, // Height computed based on the aspect ratio
              child: _getProjectImage(project), // This will display the image
            ),
            // Text content below the image
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }
}
