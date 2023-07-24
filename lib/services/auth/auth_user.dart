//THE APP'S CURRENT USER (WILL BE OF A SPECIFIC AUTH PROVIDER)
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/material.dart';

//In our app, all we need to know about the user is if its email is verified
@immutable
class AuthUser {
  const AuthUser({required this.isEmailVerified});
  final bool isEmailVerified;

  factory AuthUser.fromFirebase(firebase_auth.User user) {
    return AuthUser(isEmailVerified: user.emailVerified);
  }
}
