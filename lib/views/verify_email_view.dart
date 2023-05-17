import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/main.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => VerifyEmailViewState();
}

class VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    //If send_email_verification is pressed, send verification email
    //User can press login to navigate to login
    //Does sending email verification throw any exceptions: (NOT YET HANDLED)
    //If login is clicked, navigate to login
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Email Verification'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text('Please verify your email:'),
              ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification().then((value) {
                      navigateToLoginView(context);
                    });
                  },
                  child: const Text('Send email verification')),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () => navigateToLoginView(context),
                  child: const Text('Login'))
            ],
          ),
        ),
      ),
    );
  }
}
