import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

void main() {
  //FutureBuilder requires the binding's BuildContext to function properly
  WidgetsFlutterBinding.ensureInitialized;

  //Passing Material App Directly helps reduce our build times in development
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Open Sans',
      ),

      home: const HomeRoute(),

      //named routes for page navigation
      routes: {
        registerRoute: (context) => const RegisterView(),
        loginRoute: (context) => const LoginView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView()
      },
      
    ),
  );
}

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  // Initialise Firebase App When the Main Route starts
  // At completion: Check current user status
  // Null -> Login Page
  // Not Null:
  // Email Verified -> Main Notes Page
  // Email NOT verified -> EMail Verification Page
  @override
  Widget build(BuildContext context) {
    AuthService service = AuthService.firebase();

    return FutureBuilder(
        future: service.initialise(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = service.currentUser;
              devtools.log('USER: ${user.toString().toUpperCase()}');
              if (user != null) {
                if (user.isEmailVerified) {
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
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
          }
        });
  }
}
