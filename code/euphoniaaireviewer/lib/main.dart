import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'preferences_model.dart'; // Import the DisplayNamePreference model
import 'card_mutable_data.dart'; // Import the CardMutableData model
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PreferencesModel()),
        ChangeNotifierProvider(create: (_) => CardMutableData()),
      ],
      child: MyApp(),
    ),
  );
}
