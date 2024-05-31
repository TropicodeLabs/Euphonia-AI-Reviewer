import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common_drawer.dart';

class ManageUsersScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const ManageUsersScreen({Key? key, required this.project}) : super(key: key);

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Colors.blue,
      ),
      drawer: CommonDrawer(project: widget.project),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Users',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .where('projects', arrayContains: widget.project['id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(
                        child: Text('No users found for this project.'));
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var user = snapshot.data!.docs[index];
                      return Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: _buildUserCard(
                              user['email'] ?? 'No Name', user['lastLogin']),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey[800]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Share the project password with users to allow them to join the project and contribute to data verification.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            _buildPasswordCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(String email, Timestamp lastLogin) {
    return Card(
      color: Colors.blue,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(email, style: TextStyle(color: Colors.white)),
        subtitle: Text("Last login: ${_parseTimestamp(lastLogin)}",
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      color: Colors.blue,
      margin: EdgeInsets.all(16.0),
      child: ListTile(
        title: TextFormField(
          obscureText: !_passwordVisible,
          initialValue: widget.project['password'],
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Project Password',
            labelStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  String _parseTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
  }
}
