import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  // Groping all the tests to test auth_service
  // We will test auth_service with mock authentication provider
  group('Mock Authentication', () {
    // We should be testing auth service but we'll test mock auth provider
    // directly to access the isInitialised flag
    final service = MockAuthProvider();

    test('Provider is initially not initialisatied', () {
      expect(service.isInitialised, false);

      // there should be no user before initialisation
      expect(service.currentUser, isNull);
    });

    test('Cannot login when not initialised', () async {
      expect(service.logIn(email: 'siya@gmail.com', password: 'you'),
          throwsA(const TypeMatcher<NotInitialisedException>()));
    });

    test('Cannot register when not initialised', () async {
      expect(service.register(email: 'siya@gmail.com', password: 'you'),
          throwsA(const TypeMatcher<NotInitialisedException>()));
    });

    test('Cannot send email verification when not initialised', () async {
      expect(service.sendEmailVerification(),
          throwsA(const TypeMatcher<NotInitialisedException>()));
    });

    test('Cannot logout when not initialised', () {
      expect(service.logOut(),
          throwsA(const TypeMatcher<NotInitialisedException>()));
    });

    service.initialise();
    test('Should be able to be initalised', () async {
      await service.initialise();
      expect(service.isInitialised, true);

      // there should be no user after initialisation
      expect(service.currentUser, isNull);
    });

    test('Initialisation should take 2 seconds', () async {
      await service.initialise();
      expect(service.isInitialised, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Creating a user should delegate to login', () async {
      final badEmailUser =
          service.register(email: 'abc@gmail.com', password: 'you');
      // bad email
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser =
          service.register(email: 'siya@gmail.com', password: 'abcpass');
      // bad password
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user =
          await service.register(email: 'siya@gmail.com', password: 'you');
      // good email and password: user should be the user we registered
      expect(service.currentUser, user);

      // recently registered user should not have a verified email
      expect(service.currentUser!.isEmailVerified, false);
    });

    test('register/logged in user should be able to get verified', () async {
      await service.sendEmailVerification();

      expect(service.currentUser!.isEmailVerified, true);
    });
  });
}

class NotInitialisedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  bool _isInitialised = false;
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
