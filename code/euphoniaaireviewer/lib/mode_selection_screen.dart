import 'package:flutter/material.dart';
import 'home.dart'; // So we can navigate to HomeScreen when "Work" is chosen
import 'play_screen.dart'; // So we can navigate to PlayScreen

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Play'),
              onPressed: () {
                // Navigate to PlayScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Work'),
              onPressed: () {
                // Navigate to the existing HomeScreen (Select a Project screen)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
