import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/main.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  //String loginException;

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

  @override
  Widget build(BuildContext context) {
    //When user presses login, sign in the user, then
    //Check for email verification, if verified, navigate to main ui
    //If user is not verified, navigate user to email verification
    //If the sign in process throws exception: (NOT YET HANDLED)
    //If register is clicked, navigate to registration
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 10,
              ),
              const Text("Email:"),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                  ),
                ),
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Password:"),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
                  ),
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;

                    try {
                      await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password)
                          .then((value) {
                        final user = FirebaseAuth.instance.currentUser;
                        // ignore: avoid_print
                        print(user);
                        //CAN WE COME HERE IF USER IS NULL? WON'T WE ONLY
                        //COME HERE AT SUCCESSFUL SIGN IN?
                        if (user != null && user.emailVerified) {
                          navigateToNotesView(context);
                        } else if (user != null && !user.emailVerified) {
                          navigateToVerifyEmailView(context);
                        }
                      });
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case 'user-not-found':
                          // print('User not found. Register an account first.');
                          break;
                        case 'invalid-email':
                          // print('The e-mail entered is invalid');
                          break;
                        case 'wrong-password':
                          // print('Incorrect password');
                          break;
                        case 'user-disabled':
                        // print(
                        // 'User disabled, please contact MyNotes on mynotes@gmail.com');
                      }
                    }
                  },
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                  child: Text('If you do not have an account, register:')),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      navigateToRegisterView(context);
                    },
                    child: const Text('Register')),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
