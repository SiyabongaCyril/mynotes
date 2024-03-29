// APP'S USER EMAIL VERIFICATION PAGEtoolbarHeight: 45,

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/navigators.dart';
import 'package:mynotes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => VerifyEmailViewState();
}

class VerifyEmailViewState extends State<VerifyEmailView> {
  bool loggingIn = false;
  // Upon pressing send email verification:
  // Send Email Verification
  // Upon pressing send email Restart:
  // Sign the recently register user out
  @override
  Widget build(BuildContext context) {
    AuthService service = AuthService.firebase();
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 35,
            title: const Text(
              'Email Verification',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),

            // Problem with this button: If a user leaves the app after registering
            // Restarts it, the leading button will be present and can't take user
            //to registration screen
            leading: IconButton(
                onPressed: () async {
                  navigateToViewAndRemoveOtherViews(context, registerRoute);
                },
                icon: const Icon(Icons.arrow_back)),
            automaticallyImplyLeading: false,
            leadingWidth: 30.0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 230, 228, 227)),
                  child: const Text(
                      "We've sent you an email verification link. Verify your email to login."),
                ),
                ElevatedButton(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.zero),
                    ),
                    onPressed: () => navigateToView(context, loginRoute),
                    child: const Text('Login')),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 230, 228, 227)),
                  child: const Text(
                      "If you have't received a verification email, re-send."),
                ),
                Row(
                  children: [
                    ElevatedButton(
                        style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.only(left: 5, right: 5)),
                        ),
                        onPressed: () async {
                          setState(() => loggingIn = true);
                          await service.sendEmailVerification().then(
                              (value) => setState(() => loggingIn = false));
                        },
                        child: const Text('Send email verification')),
                    const SizedBox(
                      width: 10,
                    ),
                    loggingIn
                        ? Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator())
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.zero),
                  ),
                  onPressed: () async {
                    await service
                        .logOut()
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
      ),
    );
  }
}
