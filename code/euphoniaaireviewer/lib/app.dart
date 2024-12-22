import 'package:flutter/material.dart';
import 'home.dart';
import 'auth_gate.dart';
import 'example_behavior.dart'; // Make sure to import the Example screen
import 'settings_screen.dart'; // Import the settings screen

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => SettingsScreen(), // Add the settings route
        // Remove '/example' from here since it requires arguments
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/example') {
          final project =
              settings.arguments as Map<String, dynamic>; // Cast to Map
          return MaterialPageRoute(
            builder: (context) {
              return Example(
                  project: project); // Pass the project to the constructor
            },
          );
        }
        return null;
      },
    );
  }
}
