import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'utils.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import 'upload_data_screen.dart';

import 'common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Add this package for the circular progress indicator

class DataDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const DataDashboardScreen({Key? key, required this.project})
      : super(key: key);

  @override
  _DataDashboardScreenState createState() => _DataDashboardScreenState();
}

class _DataDashboardScreenState extends State<DataDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final projectId = widget.project['id'];

    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 247, 247, 247), // Dark background color
      appBar: AppBar(
        title: Text(widget.project['title'] as String),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      drawer: CommonDrawer(project: widget.project),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .doc("Projects/$projectId")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red));
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("No data available",
                          style: TextStyle(color: Colors.white));
                    } else {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final numberOfClips = data['numberOfClips'] as int? ?? 0;
                      final numberOfVerifications =
                          data['numberOfVerifications'] as int? ?? 0;
                      final progressPercentage = numberOfClips > 0
                          ? (numberOfVerifications / numberOfClips)
                          : 0;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDataCard(
                                  'Total clips', numberOfClips.toString()),
                              _buildDataCard('Total verifications',
                                  numberOfVerifications.toString()),
                            ],
                          ),
                          const SizedBox(height: 100),
                          const Text(
                            'Verification Progress',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          CircularPercentIndicator(
                            radius: 120.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: progressPercentage.toDouble(),
                            center: Text(
                              "${(progressPercentage * 100).toStringAsFixed(2)}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.black),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.blue,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value) {
    return Card(
      color: Colors.blue,
      child: Container(
        width: 400,
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          trailing: Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
