import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_utils.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/Logo-08.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text(
                        'Welcome to Euphonia AI Reviewer, please sign in!')
                    : const Text(
                        'Welcome to Euphonia AI Reviewer, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            // sideBuilder: (context, shrinkOffset) {
            //   return Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: AspectRatio(
            //       aspectRatio: 1,
            //       child: Image.asset('assets/flutterfire_300x.png'),
            //     ),
            //   );
            // },
          );
        }
        final user = snapshot.data;
        if (user == null) {
          // This should theoretically never happen since snapshot.hasData is true
          // But it's good practice to handle this case
          return const Text('Unexpected error. Please try to log in again.');
        }
        FirebaseUtils.addUser(user); // snapshot.data is the User
        return const HomeScreen();
      },
    );
  }
}
