import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotAProjectAdminScreen extends StatelessWidget {
  const NotAProjectAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Projects Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You do not have any projects.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
