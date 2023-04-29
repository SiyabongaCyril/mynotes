import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  //FutureBuilder requires the binding's BuildContext to function Properly
  WidgetsFlutterBinding.ensureInitialized;
  //Passing Material App Directly helps reduce our build times through hot reloads
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomeRoute(),
      routes: {
        '/register/': (context) => const RegisterView(),
        '/login/': (context) => const LoginView(),
        '/notes/': (context) => const NotesView(),
        '/home/': (context) => const HomeRoute(),
        '/verify-email/': (context) => const VerifyEmailView()
      },
    ),
  );
}

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              print('user: $user');
              if (user != null) {
                if (user.emailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }

            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

//named navigators access functions
void navigateToLoginView(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
}

void navigateToNotesView(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/notes/', (route) => false);
}

void navigateToRegisterView(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/register/', (route) => false);
}

void navigateToHomeRoute(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('/home/', (route) => false);
}

void navigateToVerifyEmailView(BuildContext context) {
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/verify-email/', (route) => false);
}
