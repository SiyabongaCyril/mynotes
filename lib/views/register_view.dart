import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/main.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
    //If register is pressed, register the use the user, then
    //If registered successfully, navigate to login view
    //If the registration process throws exception: (NOT YET HANDLED)
    //If login is clicked, navigate to login
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registration'),
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
                  constraints: BoxConstraints(),
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
                          .createUserWithEmailAndPassword(
                              email: email, password: password)
                          .then((value) {
                        navigateToLoginView(context);
                      });
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case 'email-already-in-use':
                          // print('Email already in use.');
                          break;
                        case 'invalid-email':
                          // print('The e-mail entered is invalid.');
                          break;
                        case 'operation-not-allowed':
                          // print(
                          // 'Operation-not-allowed, please contact MyNotes mynotes@gmail.com');
                          break;
                        case 'weak-password':
                        // print('Weak-password. Paaword should ****');
                      }
                    }
                  },
                  child: const Text("Register"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                  child: Text('If you already have an account, login:')),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      navigateToLoginView(context);
                    },
                    child: const Text('Login')),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
