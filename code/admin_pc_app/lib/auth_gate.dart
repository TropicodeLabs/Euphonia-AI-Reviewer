import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_project_screen.dart';

import 'list_projects_screen.dart';
import 'firebase_utils.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<List<Map<String, dynamic>>> _fetchUserProjects(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('projects')
          .get();

      return snapshot.docs
          .map((doc) => {
                'projectId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      // Handle errors or return an empty list
      print('Error fetching projects: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/AppIcon.jpg'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to FlutterFire, please sign in!')
                    : const Text('Welcome to Flutterfire, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/AppIcon.jpg'),
                ),
              );
            },
          );
        } else {
          final user = FirebaseAuth.instance.currentUser;
          // User is logged in, check for projects
          if (user == null) {
            // This should theoretically never happen since snapshot.hasData is true
            // But it's good practice to handle this case
            return const Text('Unexpected error. Please try to log in again.');
          }
          // Detect if the user is new, if it is, add it to the database
          FirebaseUtils.addUser(user);
          // Use _fetchUserProjects in FutureBuilder
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseUtils.getProjects(user.uid),
            builder: (context, projects) {
              if (projects.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (projects.hasError || projects.data == null) {
                return const Center(child: Text('Error fetching projects'));
              } else if (projects.data!.isEmpty) {
                // No projects found, navigate to CreateProjectScreen
                return const CreateProjectScreen();
              } else {
                // Projects exist, pass them to ListProjectsScreen
                return ListProjectsScreen(projects: projects.data!);
              }
            },
          );
        }
      },
    );
  }
}
