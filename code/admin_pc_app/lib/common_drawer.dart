import 'package:flutter/material.dart';
import 'upload_data_screen.dart';

class CommonDrawer extends StatelessWidget {
  final Map<String, dynamic> project;

  const CommonDrawer({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
// Add the drawer header
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/data_dashboard_screen',
                  arguments: project);
            },
          ),
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('Upload'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadDataScreen(project: project),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('Download'),
            onTap: () {
              Navigator.pushNamed(context, '/download_data_screen',
                  arguments: project);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Manage users'),
            onTap: () {
              Navigator.pushNamed(context, '/manage_users_screen',
                  arguments: project);
            },
          ),
          // navigate back to the list of projects
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text('Back to projects'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
