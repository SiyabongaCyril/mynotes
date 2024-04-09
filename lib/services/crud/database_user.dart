// Represents a single user
import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/crud/notes_service.dart';

@immutable
class DatabaseUser {
  const DatabaseUser({required this.id, required this.email});

  final int id;
  final String email;

  // Allow Dart to create a user from a map
  DatabaseUser.fromMap(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  // Allow Dart to export a user as a map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      emailColumn: email,
    };
  }

  // Override toString to make it easier to see information about
  // each user when printing/logging
  @override
  String toString() {
    return 'DatabaseUser{id: $id, email: $email}';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  get hashCode => id.hashCode;
}
