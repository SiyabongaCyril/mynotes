// Import the necessary packages and files
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/material.dart';

// Define the AuthUser class, which represents the current user of the app
@immutable
class AuthUser {
  // Define the properties of the AuthUser class
  const AuthUser({required this.isEmailVerified});
  final bool isEmailVerified;

  // Define a factory method to create an AuthUser object
  // from a Firebase user object
  factory AuthUser.fromFirebase(firebase_auth.User user) {
    // Return a new AuthUser object with the email verification status
    // of the Firebase user
    return AuthUser(isEmailVerified: user.emailVerified);
  }
}
