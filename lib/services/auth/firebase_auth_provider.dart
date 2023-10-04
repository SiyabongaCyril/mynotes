// Import the necessary packages and files
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

// Define the FirebaseAuthProvider class, which implements the
// AuthProvider interface
class FirebaseAuthProvider implements AuthProvider {
  // Get the current user
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  // Log in a user with the provided email and password
  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      // Sign in the user with Firebase authentication
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Get the current user
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific authentication exceptions
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'wrong-password':
          throw WrongPasswordAuthException();
        case 'user-disabled':
          throw UserDisabledAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  // Log out the current user
  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  // Register a new user with the provided email and password
  @override
  Future<AuthUser> register(
      {required String email, required String password}) async {
    try {
      // Create a new user with Firebase authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Get the current user
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific authentication exceptions
      switch (e.code) {
        case 'email-already-in-use':
          throw EmailAlreadyInUseAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'operation-not-allowed':
          throw OperationNotAllowedAuthException();
        case 'weak-password':
          throw WeakPasswordAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  // Send an email verification to the current user
  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  // Initialise the Firebase app
  @override
  Future<void> initialise() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
