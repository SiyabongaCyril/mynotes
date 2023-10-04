// Import the AuthUser class from the auth_user.dart file
import 'package:mynotes/services/auth/auth_user.dart';

// Define the blueprint for an authentication provider
abstract class AuthProvider {
  // Initialise an auth service (if that specific auth service requires
  // initialisation before being used)
  Future<void> initialise();

  // Get the current user
  AuthUser? get currentUser;

  // Log in a user with the provided email and password
  Future<AuthUser> logIn({required String email, required String password});

  // Register a new user with the provided email and password
  Future<AuthUser> register({required String email, required String password});

  // Log out the current user
  Future<void> logOut();

  // Send an email verification to the current user
  Future<void> sendEmailVerification();
}
