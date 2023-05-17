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
  //Passing Material App Directly helps reduce our build times durings hot reloads
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      //enable dark theme for the app
      darkTheme: ThemeData.dark(),
      home: const HomeRoute(),

      //named routes for routing pages/views
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
    //Initialise Firebase App When the Main Route starts
    //Check current user status: Null->Login, User(verified email)->Notes,
    //User(unverified email)->Email Verification
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              // ignore: avoid_print
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
              return const SafeArea(
                child: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
          }
        });
  }
}

//named navigators access functions
//No need to use Navigator.of... all the time
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
