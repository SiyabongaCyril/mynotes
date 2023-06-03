//THE APP'S DEFITION OF USER AUTHENTICATION
import 'package:mynotes/services/auth/auth_user.dart';

//Defined the blue print for authentication

abstract class AuthProvider {
  //initialise an auth service (if that specific auth service requires initialisation before being used)
  Future<void> initialise();

  AuthUser? get currentUser;
  Future<AuthUser> logIn({required String email, required String password});
  Future<AuthUser> register({required String email, required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
}
