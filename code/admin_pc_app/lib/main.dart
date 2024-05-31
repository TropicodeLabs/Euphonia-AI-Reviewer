import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'display_name_preference.dart'; // Import the DisplayNamePreference model
// import 'card_deck_model.dart'; // Import the CardDeckModel
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  )
      .then((value) => print('Firebase initialized successfully'))
      .catchError((e) => print('Failed to initialize Firebase: $e'));

  runApp(
    MyApp(),
  );
}
