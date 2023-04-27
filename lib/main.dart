import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/views/login_view.dart';
import '../firebase_options.dart';

void main() {
  //FutureBuilder requires the binding's BuildContext to function Properly
  WidgetsFlutterBinding.ensureInitialized;
  //Passing Material App Directly helps reduce our build times through hot reloads
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: const LoginView(),
  ));
}
