import 'package:flutter/material.dart';

class DataPolicyScreen extends StatelessWidget {
  const DataPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a sage color
    const Color sage = Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Data Policy', style: TextStyle(color: Colors.white)),
        backgroundColor: sage,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: sage,
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('Public Projects:', sage),
            buildBulletPoint(
                'Public projects are visible to all users of the platform.',
                sage),
            buildBulletPoint(
                'Any user can contribute annotations to public projects without needing special access or permissions.',
                sage),
            const SizedBox(height: 16),
            buildSectionTitle('Private Projects:', sage),
            buildBulletPoint(
                'Private projects are only visible to users who have been granted access by the project administrator.',
                sage),
            buildBulletPoint(
                'Access to annotate private projects requires a password, which is provided by the project administrator.',
                sage),
            const SizedBox(height: 16),
            buildSectionTitle('Trusted Users and Data Presentation:', sage),
            buildBulletPoint(
                'Data will be presented to annotators until a Trusted User marks it as complete or until a consensus is reached.',
                sage),
            buildBulletPoint(
                'Consensus is reached when a majority of annotators agree on a label, as specified by the project administrator.',
                sage),
            buildBulletPoint(
                'This feature empowers administrators to maintain high-quality data within their projects.',
                sage),
            const SizedBox(height: 16),
            buildSectionTitle('Data Privacy:', sage),
            buildBulletPoint(
                'We are committed to protecting your privacy and handling your data with the utmost care.',
                sage),
            buildBulletPoint(
                'Your data will not be shared with any third parties without your explicit consent.',
                sage),
            buildBulletPoint(
                'Any potential waiver of data ownership for collaborative or promotional purposes will be communicated and agreed upon directly through the app.',
                sage),
            const SizedBox(height: 16),
            Text(
              'All users are encouraged to respect the privacy and intellectual property of project administrators and contributors. '
              'Misuse of the platform or violation of the data policy may result in access restrictions or account termination.\n\n'
              'We reserve the right to update this policy as necessary to reflect changes in our services or legal requirements. '
              'Users will be notified of significant changes, but you are encouraged to review the policy periodically.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget buildBulletPoint(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
