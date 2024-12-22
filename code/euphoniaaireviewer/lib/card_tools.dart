import 'package:flutter/material.dart';
import 'tags_model.dart';
import 'example_candidate_model.dart';
import 'user_confidence_selector.dart';
import 'card_mutable_data.dart';
import 'package:provider/provider.dart';

class CardToolsWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final ExampleCandidateModel candidate;

  const CardToolsWidget({
    Key? key,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.candidate,
  }) : super(key: key);

  @override
  _CardToolsWidgetState createState() => _CardToolsWidgetState();
}

class _CardToolsWidgetState extends State<CardToolsWidget> {
  bool showTags = true;
  bool isEditMode = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth;

    return Container(
      width: containerWidth, // Use the calculated width
      // The height is explicitly defined to ensure the Stack knows its size.
      height: 50, // Define an appropriate height based on your content
      padding: EdgeInsets.all(
          0), // Padding for aesthetic spacing inside the container
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the container
        borderRadius:
            BorderRadius.circular(10), // Rounded corners for the container
      ),
      child: SingleChildScrollView(
        // Allows for scrolling if content exceeds the container height
        child: Column(
          children: [
            _buildUserConfidenceSelector(),
            // _buildTagControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserConfidenceSelector() {
    return Consumer<CardMutableData>(
      builder: (_, mutableData, __) {
        int tagsCount = mutableData.tags
            .length; // Assuming CardMutableData holds the tags and can give their count
        return Row(
          children: [
            UserConfidenceSelector(
              onSelected: (selectedConfidence) {
                print("Selected confidence: $selectedConfidence");
                mutableData.setUserConfidence(selectedConfidence);
              },
            ),
            Container(
              width:
                  10.0, // Horizontal space between the confidence selector and tags
            ),
            TextButton(
              onPressed: () => _showTagsDialog(
                  context), // This method will show the tags dialog
              child: Text("Tags: $tagsCount"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
            Spacer(), // This will push the bookmark button to the end of the row
            // IconButton(
            //   icon: Icon(Icons.bookmark_border, size: 35),
            //   onPressed: () {
            //     // Implement your logic for the bookmark action
            //     print("Bookmark icon pressed");
            //   },
            // ),
          ],
        );
      },
    );
  }

  void _showTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<CardMutableData>(
            builder: (_, mutableData, __) => AlertDialog(
                  title: Text("Manage Tags"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListBody(
                          children: <Widget>[
                            Text("Tags:"),
                            _buildTagList(),
                          ],
                        ),
                        if (mutableData.tags.length < 15)
                          TextButton(
                            onPressed: () => _showAddTagDialog(),
                            child: Text("Add Tag"),
                          ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      },
    );
  }

  Widget _buildTagList() {
    // This method builds a list of tags.
    // It's abstracted for clarity and focuses on displaying tags.
    print("buildTagList called");
    return Consumer<CardMutableData>(
        builder: (_, mutableData, __) => Wrap(
              spacing: 8.0, // Horizontal space between tags
              runSpacing: 4.0, // Vertical space between lines of tags
              children: mutableData.tags.map((tag) {
                print("ON BUILDTAGLIST tag.text is ${tag.text}");
                return Chip(
                  label: Text(tag.text),
                  onDeleted: isEditMode
                      ? () => _deleteTag(tag)
                      : null, // Conditional delete button
                );
              }).toList(),
            ));
  }

  Widget buildToolsHidden() {
    return IconButton(
      icon: Icon(Icons.more),
      onPressed: widget.onToggleVisibility,
    );
  }

  Future<void> _showAddTagDialog() async {
    String tagText = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Tag'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('(e.g. #rain, #cicadas, #growling, #notenumber023)'),
                TextField(
                  onChanged: (value) {
                    tagText = value;
                  },
                  decoration: InputDecoration(
                    // hint text should be up to 20 characters long
                    hintText: "Up to 20 letters, numbers or spaces",
                  ),
                  maxLength: 20,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer<CardMutableData>(
              builder: (_, mutableData, __) => TextButton(
                child: Text('Add'),
                onPressed: () {
                  // Regular expression to match only letters and numbers
                  final RegExp regExp = RegExp(r'^[a-zA-Z0-9 ]+$');
                  // Check if tagText matches the regular expression and its length is <=20
                  print("regexp value is ${regExp.hasMatch(tagText)}");
                  print(
                      "tagText value is $tagText and length is ${tagText.length}");
                  print(
                      "below condtition value is: ${regExp.hasMatch(tagText) && tagText.length <= 20}");
                  if (regExp.hasMatch(tagText) && tagText.length <= 20) {
                    // if regexp is true it is because the tagText is valid
                    mutableData.addTag(GeneralTag(tagText));

                    Navigator.of(context).pop();
                  } else {
                    // Show error message if the tag doesn't meet the criteria
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Tag'),
                          content: Text(
                              'Tags must be up to 20 characters long and contain only letters and numbers.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the error dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTag(Tag tag) {
    final mutableData = Provider.of<CardMutableData>(context, listen: false);

    mutableData.removeTag(tag);
  }
}
