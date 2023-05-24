// APP'S USER REGISTRATION PAGE

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/utilities/navigators.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/constants/routes.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool loggingIn = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Upon successful Registration:
  // Send Email Verification
  // Navigate to Email Verification Page
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          title: const Text('Registration',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              )),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 10,
              ),
              const Text("Email:"),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.elliptical(5, 5)),
                      ),
                      contentPadding: EdgeInsets.only(left: 10, right: 10)),
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Password:"),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _password,
                  decoration: const InputDecoration(
                      constraints: BoxConstraints(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.elliptical(5, 5)),
                      ),
                      contentPadding: EdgeInsets.only(left: 10, right: 10)),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.zero),
                    ),
                    onPressed: () async {
                      setState(() => loggingIn = true);
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: email, password: password)
                            .then((value) async {
                          final user = FirebaseAuth.instance.currentUser;
                          devtools
                              .log('USER: ${user.toString().toUpperCase()}');
                          await user?.sendEmailVerification().then((value) {
                            setState(() => loggingIn = false);
                            navigateToView(context, verifyEmailRoute);
                          });
                        });
                      } on FirebaseAuthException catch (e) {
                        setState(() => loggingIn = false);
                        switch (e.code) {
                          case 'email-already-in-use':
                            await showErrorDialog(
                                context, "email-already-in-use");
                            break;
                          case 'invalid-email':
                            await showErrorDialog(context, "invalid-email");
                            break;
                          case 'operation-not-allowed':
                            await showErrorDialog(context,
                                "Operation-not-allowed, please contact MyNotes mynotes@gmail.com");
                            break;
                          case 'weak-password':
                            await showErrorDialog(context, "weak-password");
                            break;
                          default:
                            await showErrorDialog(context, "Error: $e.code");
                        }
                      } catch (e) {
                        setState(() => loggingIn = false);
                        await showErrorDialog(
                            context, "Error: ${e.toString()}");
                      }
                    },
                    child: const Text("Register"),
                  ),
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
                height: 20,
              ),
              const Text('If you already have an account, login:'),
              ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.zero),
                  ),
                  onPressed: () {
                    navigateToViewAndRemoveOtherViews(context, loginRoute);
                  },
                  child: const Text('Login')),
            ]),
          ),
        ),
      ),
    );
  }
}
