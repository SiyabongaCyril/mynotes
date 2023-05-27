//Login Exceptions
class UserNotFoundAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class UserDisabledAuthException implements Exception {}

//Register Exceptions
class EmailAlreadyInUseAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class OperationNotAllowedAuthException implements Exception {}

//Generic Exceptions
class GenericAuthException implements Exception {}

//It's possible to register a user without an exception but user is null,
//User wasn't signed in to Firebase Auth
class UserNotLoggedInAuthException implements Exception {}
