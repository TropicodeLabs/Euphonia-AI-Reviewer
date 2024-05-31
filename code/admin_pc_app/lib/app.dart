import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'list_projects_screen.dart';
import 'settings_screen.dart'; // Import the settings screen
import 'data_dashboard_screen.dart';
import 'upload_data_screen.dart';
import 'download_data_screen.dart';
import 'manage_users_screen.dart';

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
        '/settings': (context) => SettingsScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        // rewrite with switch statement
        switch (settings.name) {
          case '/data_dashboard_screen':
            final project =
                settings.arguments as Map<String, dynamic>; // Cast to Map
            return MaterialPageRoute(
              builder: (context) {
                return DataDashboardScreen(project: project);
              },
            );
          case '/list_projects_screen':
            final projects = settings.arguments as List<Map<String, dynamic>>;
            return MaterialPageRoute(
              builder: (context) {
                return ListProjectsScreen(projects: projects);
              },
            );
          case '/upload_data_screen':
            final project =
                settings.arguments as Map<String, dynamic>; // Cast to Map
            return MaterialPageRoute(
              builder: (context) {
                return UploadDataScreen(project: project);
              },
            );
          case '/data_dashboard_screen':
            final project = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) {
                return DataDashboardScreen(project: project);
              },
            );
          case '/download_data_screen':
            final project =
                settings.arguments as Map<String, dynamic>; // Cast to Map
            return MaterialPageRoute(
              builder: (context) {
                return DownloadDataScreen(project: project);
              },
            );
          case '/manage_users_screen':
            final project =
                settings.arguments as Map<String, dynamic>; // Cast to Map
            return MaterialPageRoute(
              builder: (context) {
                return ManageUsersScreen(project: project);
              },
            );
          default: // maybe we should return a page that does not requires arguments, like a home page or not found page
            final project =
                settings.arguments as Map<String, dynamic>; // Cast to Map
            return MaterialPageRoute(
              builder: (context) {
                return DataDashboardScreen(project: project);
              },
            );
        }
      },
    );
  }
}
