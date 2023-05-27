// APP'S USER LOGIN PAGE

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/navigators.dart';
import 'package:mynotes/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
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

  // Upon pressing LOGIN: Check if User Email is Verified
  // Verified -> Main Notes Page
  // Not Verified -> Email Verifiation Page
  @override
  Widget build(BuildContext context) {
    AuthService service = AuthService.firebase();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          title: const Text(
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
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
                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                  ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.elliptical(5, 5)),
                    ),
                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                  ),
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
                        await service
                            .logIn(email: email, password: password)
                            .then((value) {
                          //CAN WE COME HERE IF USER IS NULL? WON'T WE ONLY
                          //COME HERE AT SUCCESSFUL SIGN IN?
                          setState(() => loggingIn = false);
                          final user = service.currentUser;
                          devtools
                              .log('USER: ${user.toString().toUpperCase()}');

                          if (user != null && user.isEmailVerified) {
                            navigateToViewAndRemoveOtherViews(
                                context, notesRoute);
                          } else if (user != null && !user.isEmailVerified) {
                            navigateToViewAndRemoveOtherViews(
                                context, verifyEmailRoute);
                          }
                        });
                      } on UserNotFoundAuthException {
                        setState(() => loggingIn = false);
                        await showErrorDialog(context, "User not found");
                      } on InvalidEmailAuthException {
                        setState(() => loggingIn = false);
                        await showErrorDialog(
                            context, "The e-mail entered is invalid");
                      } on WrongPasswordAuthException {
                        setState(() => loggingIn = false);
                        await showErrorDialog(context, "Incorrect password");
                      } on UserDisabledAuthException {
                        setState(() => loggingIn = false);
                        await showErrorDialog(context,
                            "user-disabled, , please contact MyNotes mynotes@gmail.com");
                      } on GenericAuthException {
                        setState(() => loggingIn = false);
                        await showErrorDialog(context, "Authentication error");
                      }
                    },
                    child: const Text("Login"),
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
              const Text('If you do not have an account, register:'),
              ElevatedButton(
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.zero),
                  ),
                  onPressed: () {
                    navigateToViewAndRemoveOtherViews(context, registerRoute);
                  },
                  child: const Text('Register')),
            ]),
          ),
        ),
      ),
    );
  }
}

/*
FirebaseAuthException catch (e) {
                        setState(() => loggingIn = false);
                        switch (e.code) {
                          case 'user-not-found':

                          case 'invalid-email':
                            
                            break;
                          case 'wrong-password':
                           
                            break;
                          case 'user-disabled':
                           
                            break;
                          default:
                            
                        }
                      } catch (e) {
                        setState(() => loggingIn = false);
                        await showErrorDialog(
                            context, "Error: ${e.toString()}");
                      }
*/
