import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();

      test('Provider should not be initially initialised', () {
        expect(provider.isInitialised, false);
      });

      test('Cannot logout if not initialised', () {
        expect(
            provider.logOut(),
            throwsA(
              const TypeMatcher<NotInitialisedException>(),
            ));
      });
    },
  );
}

class NotInitialisedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialised = false;
  AuthUser? _user;

  bool get isInitialised => _isInitialised;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialise() async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    ).then((value) => _isInitialised = true);
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    if (!isInitialised) throw NotInitialisedException();
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    if (email == "abc@gmail.com") throw UserNotFoundAuthException();
    if (password == "abcpass") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialised) throw NotInitialisedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1)).then(
      (value) => _user = null,
    );
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (!isInitialised) throw NotInitialisedException();
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    // When creating a user e.g using Firebase, Firebase creates a user
    // then logs them in automatically
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialised) throw NotInitialisedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
