import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<List<Map<String, dynamic>>> getProjects(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Projects')
          .where('createdBy', isEqualTo: userId)
          .get();

      var imageUrlFutures = querySnapshot.docs.map((doc) async {
        Map<String, dynamic> projectData = doc.data() as Map<String, dynamic>;
        String imagePathBasename =
            projectData['imagePathBasename'] ?? 'default';
        if (imagePathBasename == 'default') {
          return {'id': doc.id, ...projectData, 'imageUrl': null};
        } else {
          try {
            String imageUrl = await _storage
                .ref('projects/${doc.id}/description/$imagePathBasename')
                .getDownloadURL();
            return {'id': doc.id, ...projectData, 'imageUrl': imageUrl};
          } catch (e) {
            print("Error fetching image URL for project ${doc.id}: $e");
            return {'id': doc.id, ...projectData};
          }
        }
      });

      List<Map<String, dynamic>> projects = await Future.wait(imageUrlFutures);
      return projects;
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

  static Future<void> updateUserLastLogin(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);
    await userRef.update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateUserIsTrusted(String userId, bool isTrusted) async {
    final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    await userRef.update({
      'isTrusted': isTrusted,
    });
  }

  static Future<void> updateUserIsAdmin(String userId, bool isAdmin) async {
    final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    await userRef.update({
      'isAdmin': isAdmin,
    });
  }

  static void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
