import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  const AuthUser(this.isEmailVerified);
  final bool isEmailVerified;

  factory AuthUser.fromFirebase(firebase_auth.User user) {
    return AuthUser(user.emailVerified);
  }
}
