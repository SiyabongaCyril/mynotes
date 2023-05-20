import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/utilities/navigators.dart';
import 'package:mynotes/constants/routes.dart';

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
              const Text(
                  "We've sent you an email verification link. Verify your email to login."),
              ElevatedButton(
                  onPressed: () =>
                      navigateToViewAndRemoveOtherViews(context, loginRoute),
                  child: const Text('Login')),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  "If you have't received a verification email, press the button below"),
              ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user
                        ?.sendEmailVerification(); /*.then((value) {
                      navigateToViewAndRemoveOtherViews(context, loginRoute);
                    });*/
                  },
                  child: const Text('Send email verification')),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance
                      .signOut()
                      .then((value) => navigateToViewAndRemoveOtherViews(
                            context,
                            registerRoute,
                          ));
                },
                child: const Text("Restart"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
