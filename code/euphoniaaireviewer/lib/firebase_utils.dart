// FirebaseUtils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class FirebaseUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

// lets make a function that will handle the addition of more projects, by
// taking in a project login password that is in the form of a string
// in the field named 'password' in the project document
// for that we will call the firebase function 'addProjectToUserList' which expects
// simply a password field only, no need to pass the project id as it will be
// automatically added to the user's project list
  static Future<void> addProjectToUserList(String password) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('addProjectToUserList');
      await callable.call({'password': password});
    } catch (e) {
      print("Error adding project to user list: $e");
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getProjects(String userId) async {
    try {
      // Get private projects the user has access to
      final DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();
      final List<String> userProjects =
          List<String>.from(userDoc.get('projects') ?? []);

      // Fetch private projects
      List<QueryDocumentSnapshot> privateProjects = [];
      if (userProjects.isNotEmpty) {
        final QuerySnapshot privateProjectsQuerySnapshot = await _firestore
            .collection('Projects')
            .where(FieldPath.documentId, whereIn: userProjects)
            .get();
        privateProjects.addAll(privateProjectsQuerySnapshot.docs);
      }

      // Fetch public projects
      final QuerySnapshot publicProjectsQuerySnapshot = await _firestore
          .collection('Projects')
          .where('isPublic', isEqualTo: true)
          .get();

      // Combine and deduplicate documents based on document ID
      final allProjects = {
        for (var doc in [
          ...privateProjects,
          ...publicProjectsQuerySnapshot.docs
        ])
          doc.id: doc
      }.values.toList();

      // Map over the combined list to fetch image URLs
      var projectsWithImages = allProjects.map((doc) async {
        Map<String, dynamic> projectData = doc.data() as Map<String, dynamic>;
        String imagePathBasename =
            projectData['imagePathBasename'] ?? 'default';
        if (imagePathBasename != 'default') {
          try {
            String imageUrl = await _storage
                .ref('projects/${doc.id}/description/$imagePathBasename')
                .getDownloadURL();
            projectData['imageUrl'] = imageUrl;
          } catch (e) {
            print("Error fetching image URL for project ${doc.id}: $e");
            // Optionally handle the error, e.g., by setting a default image URL
            projectData['imageUrl'] = null;
          }
        } else {
          projectData['imageUrl'] = null; // Handle the default image case
        }
        return {'id': doc.id, ...projectData};
      });

      return await Future.wait(projectsWithImages);
    } catch (e) {
      print("Error getting projects: $e");
      return [];
    }
  }

  static Future<bool> checkIfFileExistsInFirebaseStorage(
      String filePath) async {
    final storageRef = FirebaseStorage.instance.ref().child(filePath);
    try {
      // Try to get the download URL
      final url = await storageRef.getDownloadURL();
      // If successful, the file exists
      return true;
    } on FirebaseException catch (e) {
      // If an error occurs, check if it's because the file doesn't exist
      if (e.code == 'object-not-found') {
        // File doesn't exist
        return false;
      }
      // Re-throw the exception if it's caused by something else
      rethrow;
    }
  }

  static void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  static Future<void> addUser(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isTrusted': false,
        'photoURL': user.photoURL,
        'isAdmin': false,
      });
    }
  }

  static Future<List<double>> getVerificationProgress(String projectId) async {
    try {
      //numberOfClips is a field within the project id
      final projectSnapshot =
          await _firestore.collection('Projects').doc(projectId).get();

      final numberOfClips = projectSnapshot.get('numberOfClips').toDouble();
      final numberOfVerifications =
          projectSnapshot.get('numberOfVerifications').toDouble();

      if (numberOfClips == 0) {
        print("Project has no clips");
        return [0.0, 0.0];
      }

      return [numberOfVerifications, numberOfClips];
    } catch (e) {
      print("Error getting verification progress: $e");
      return [0.0, 0.0];
    }
  }

  static Future<int> getSkippedVerifications(
      String userId, String projectId) async {
    try {
      final skippedVerificationsSnapshot = await _firestore
          .collection('SkippedClips')
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: userId)
          .where('skippedReason', isEqualTo: 'user_skipped')
          .get();

      return skippedVerificationsSnapshot.size;
    } catch (e) {
      print("Error getting skipped verifications: $e");
      return 0;
    }
  }

  //final verificationsByUser = await FirebaseUtils.getVerificationsByUser(
  // FirebaseAuth.instance.currentUser!.uid, projectId);
  static Future<int> getVerificationsByUser(
      String userId, String projectId) async {
    try {
      final verificationsByUserSnapshot = await _firestore
          .collection('Verifications')
          .where('projectId', isEqualTo: projectId)
          .where('verifiedBy', isEqualTo: userId)
          .get();

      return verificationsByUserSnapshot.size;
    } catch (e) {
      print("Error getting verifications by user: $e");
      return 0;
    }
  }
}
