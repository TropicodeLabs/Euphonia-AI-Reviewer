import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'search_screen.dart';
import 'example_candidate_model.dart';
import 'example_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'tags_model.dart';
import 'card_tools.dart';
import 'card_mutable_data.dart';

class Example extends StatefulWidget {
  final Map<String, dynamic> project; // Change this to accept a Map

  const Example({
    super.key,
    required this.project,
  });

  @override
  State<Example> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<Example> {
  final CardSwiperController controller = CardSwiperController();
  List<ExampleCard> cards = []; // Make 'cards' mutable
  // BORRAR SUPUESTAMENTE
  bool _canUndo = false;
  // Example state variable in your widget
  bool _isSubmitting = false;
  IconData _feedbackIcon = Icons.hourglass_empty; // Default icon
  bool _toolsVisible = false; // Add this line to control visibility of tools

  @override
  void initState() {
    super.initState();
    // Assuming 'initializeCards' is a method that creates 3 ExampleCard widgets
    initializeCards();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // Use the AppBar's leading widget to place a home button
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate back to the home screen
              Navigator.pushNamed(context, '/home');
            },
          ),
          // title: Text(''), // Optionally, provide a title for the AppBar
          //add settings button to the appbar
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            IconButton(
              icon: Icon(Icons.help_outline), // "?" help button
              onPressed: _showHelpDialog, // Method to show help dialog
            ),
          ],
        ),
        body: Stack(
          children: [
            CardSwiper(
              controller: controller,
              isLoop: true,
              cardsCount:
                  cards.length, // Use the length of uiDeck from the model
              allowedSwipeDirection: AllowedSwipeDirection.only(
                right: true,
                left: true,
                up: false,
                down: true,
              ),
              onSwipe: (previousIndex, currentIndex, direction) async {
                return await _onSwipe(previousIndex, currentIndex, direction);
              },
              onUndo: _onUndo,
              numberOfCardsDisplayed: 2,
              backCardOffset: const Offset(40, 40),
              padding: const EdgeInsets.all(24.0),
              cardBuilder: (context, index, horizontalThresholdPercentage,
                      verticalThresholdPercentage) =>
                  cards[index], // Use the card from uiDeck in the model
            ),
            if (_isSubmitting) //TODO: implement better UI for loading state
              Positioned(
                top: 32,
                right: 32,
                child: Icon(
                  _feedbackIcon,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void initializeCards() {
    cards = List.generate(
      3,
      (index) => ExampleCard.withDefaults(
          projectId: widget.project['id'], buildCount: 0),
    );
    //then increment their buildCount
    cards.forEach((card) {
      card.buildCount++;
      print("just built a card with buildCount: ${card.buildCount}");
    });
  }

  void refreshCardData(int index) {
    // Trigger data refresh for a specific card based on index
    if (index >= 0 && index < cards.length) {
      cards[index].buildCount++;
    }
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    setState(() {
      _isSubmitting = true;
      _feedbackIcon = Icons.hourglass_empty;
    });
    debugPrint(
        'The card at index $previousIndex was swiped to the ${direction.name}.');

    final mutableData = Provider.of<CardMutableData>(context, listen: false);
    List<String> tagsText = mutableData.tags
        .whereType<GeneralTag>()
        .map((tag) => tag.text)
        .toList();
    String userConfidence = mutableData.userConfidence;
    mutableData.clearTags(); // Clear tags after submission

    if (direction == CardSwiperDirection.left) {
      final labels = widget.project['labels'] as Map<String, dynamic>;
      // consult the preferences to see commonNames or speciesCodes

      final List<String> commonNames = List<String>.from(labels['commonName']);
      final List<String> speciesCodes =
          List<String>.from(labels['speciesCode']);

      final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(
              speciesCodes: speciesCodes,
              commonNames: commonNames,
              // cards[previousIndex].candidate, could be null, handle that
              candidate: cards[previousIndex]?.candidate,
            ),
          ));
      print('here the previousIndex is $previousIndex;');
      print('here the currentIndex is $currentIndex;');
      print('result is $result');
      // result is xpected to be either null or an int
      if (result != null) {
        //  ############################################################ USER SWIPED LEFT ########################################################
        // Call cloud function to submit the label confirmation
        print(commonNames[result]);
        _submitLabelConfirmation(result, cards[previousIndex]!.candidate,
                tagsText, userConfidence)
            .then((_) {
          setState(() {
            _feedbackIcon = Icons.check;
            _canUndo = true;
          });
        }).catchError((error) {
          setState(() {
            _feedbackIcon = Icons.error;
          });
        }).whenComplete(() {
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _isSubmitting = false;
            });
          });
        });
        cards[previousIndex].buildCount++;
        return true;
      }
    } else if (direction == CardSwiperDirection.right) {
      // Handle right swipe (agree with prediction)
      final ExampleCandidateModel candidate = cards[previousIndex]!.candidate;

      // Directly use the predicted label information
      final predictedCommonName = candidate.predictedCommonName;
      final predictedSpeciesCode = candidate.predictedSpeciesCode;

      // Submit the label confirmation using the predicted information
      _submitLabelConfirmationUsingPrediction(predictedSpeciesCode,
              predictedCommonName, candidate, tagsText, userConfidence)
          .then((_) {
        setState(() {
          _feedbackIcon = Icons.check;
          _canUndo = true;
        });
      }).catchError((error) {
        setState(() {
          _feedbackIcon = Icons.error;
        });
      }).whenComplete(() {
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _isSubmitting = false;
          });
        });
      });

      // Update model
      cards[previousIndex].buildCount++;
      // call mutable data refresh to set tags to 0
      return true;
    } else if (direction == CardSwiperDirection.bottom) {
      // Handle down swipe (skip/unknown)
      final ExampleCandidateModel candidate = cards[previousIndex]!.candidate;

      _submitLabelConfirmationSkipped(candidate, tagsText, userConfidence)
          .then((_) {
        setState(() {
          _feedbackIcon = Icons.check;
          _canUndo = true;
        });
      }).catchError((error) {
        setState(() {
          _feedbackIcon = Icons.error;
        });
      }).whenComplete(() {
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _isSubmitting = false;
          });
        });
      });

      // Update model
      cards[previousIndex].buildCount++;

      return true;
    }
    return false;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    if (_canUndo) {
      debugPrint(
        'The card $currentIndex was undod from the ${direction.name}',
      );
      setState(() {
        _canUndo = false; // This change now triggers a rebuild
      });
      return true;
    } else {
      debugPrint('Cannot undo again. Only one undo is allowed at a time.');
      return false;
    }
  }

  Future<void> _submitLabelConfirmationSkipped(ExampleCandidateModel candidate,
      List<String> tagsText, String userConfidence) async {
    try {
      // print what will be sent
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('projectId: ${widget.project['id']}');
      print('audioClipId: ${candidate.audioClipId}');
      await FirebaseFunctions.instance
          .httpsCallable('submitLabelConfirmationSkipped')({
        'projectId': widget.project['id'],
        'audioClipId': candidate.audioClipId,
        'tags': tagsText,
        'userConfidence': userConfidence,
        'skippedReason': 'user_skipped',
      });
      // Handle successful submission
    } catch (e) {
      print('_submitLabelConfirmationSkipped Error: $e');
      // Handle errors
    }
  }

  Future<void> _submitLabelConfirmationUsingPrediction(
      String speciesCode,
      String commonName,
      ExampleCandidateModel candidate,
      List<String> tagsText,
      String userConfidence) async {
    try {
      // print what will be sent
      // compute label index
      final labelIndex = widget.project['labels']['speciesCode']
          .indexOf(speciesCode); // assuming speciesCode is unique
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('projectId: ${widget.project['id']}');
      print('speciesCode: $speciesCode');
      print('commonName: $commonName');
      print('audioClipId: ${candidate.audioClipId}');
      print('labelIndex: $labelIndex');
      await FirebaseFunctions.instance
          .httpsCallable('submitLabelConfirmation')({
        'labelIndex': labelIndex,
        'projectId': widget.project['id'],
        'speciesCode': speciesCode,
        'commonName': commonName,
        'audioClipId': candidate.audioClipId,
        'tags': tagsText,
        'userConfidence': userConfidence,
      });
      // Handle successful submission
    } catch (e) {
      print('_submitLabelConfirmationUsingPrediction Error: $e');
      // Handle errors
    }
  }

  Future<void> _submitLabelConfirmation(
      int selectedLabelIndex,
      ExampleCandidateModel candidate,
      List<String> tagsText,
      String userConfidence) async {
    // data validation
    if (selectedLabelIndex < 0 ||
        selectedLabelIndex >= widget.project['labels']['commonName'].length ||
        candidate == null) {
      // TODO: Handle invalid label index and errors
      return;
    }
    // Assuming `selectedLabelIndex` can be used to get the label details
    final selectedSpeciesCode =
        widget.project['labels']['speciesCode'][selectedLabelIndex];
    final selectedCommonName =
        widget.project['labels']['commonName'][selectedLabelIndex];
    try {
      // Call your Firebase function with the selected label details
      //  pass the project id, index, commonname, speciescode, use widget.project['id']
      // print what will be sent
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('projectId: ${widget.project['id']}');
      print('labelIndex: $selectedLabelIndex');
      print('commonName: $selectedCommonName');
      print('speciesCode: $selectedSpeciesCode');
      print('audioClipId: ${candidate.audioClipId}');
      await FirebaseFunctions.instance
          .httpsCallable('submitLabelConfirmation')({
        'projectId': widget.project['id'],
        'labelIndex':
            selectedLabelIndex, //these are redundant but will be used for data validation in the cloud
        'commonName':
            selectedCommonName, //these are redundant but will be used for data validation in the cloud
        'speciesCode':
            selectedSpeciesCode, //these are redundant but will be used for data validation in the cloud
        'audioClipId': candidate.audioClipId,
        'tags': tagsText,
        'userConfidence': userConfidence,
      });
      // Handle successful submission, e.g., show a success message
    } catch (e) {
      // Handle errors, e.g., show an error message
      print('_submitLabelConfirmation Error: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reviewing Guide"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "Review each audio clip and its AI-predicted label. Use the spectrogram 🔊 to listen."),
                Text("👉 Swipe right if the prediction matches."),
                Text("👈 Swipe left to correct the label if needed."),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.tag, size: 20, color: Colors.black),
                      ),
                      TextSpan(
                        text:
                            " Tag unusual or notable sounds. Add up to 15 tags per clip to help refine our AI.\n",
                      ),
                      WidgetSpan(
                        child: Icon(Icons.flag, size: 20, color: Colors.black),
                      ),
                      TextSpan(
                        text: " Indicate your confidence level on each review.",
                      ),
                      // bookmark icon to save
                      WidgetSpan(
                        child:
                            Icon(Icons.bookmark, size: 20, color: Colors.black),
                      ),
                      TextSpan(
                        text: " Bookmark clips for future reference.",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Your expertise is invaluable. Thank you for contributing to scientific discovery! 🐦 🐋 🐒",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok, got it!'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
