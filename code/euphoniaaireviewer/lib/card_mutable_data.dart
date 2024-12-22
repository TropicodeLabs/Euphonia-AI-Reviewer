import 'package:flutter/material.dart';
import 'tags_model.dart';

class CardMutableData extends ChangeNotifier {
  List<Tag> _tags = [];
  String _userConfidence = "Completely sure";

  List<Tag> get tags => _tags;
  String get userConfidence => _userConfidence;

  void addTag(Tag tag) {
    _tags.add(tag);
    print("Added tag: ${tag.text}");
    print("Tags: ");
    _tags.forEach((element) {
      print(element.text);
    });
    notifyListeners();
  }

  void removeTag(Tag tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void setUserConfidence(String confidence) {
    if (_userConfidence != confidence) {
      _userConfidence = confidence;
      notifyListeners();
    }
  }

  void clearTags() {
    _tags.clear();
    notifyListeners();
  }
}
