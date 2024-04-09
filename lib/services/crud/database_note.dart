// Represents a single note
import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/crud/notes_service.dart';

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  // Allow Dart to create a note from a map
  DatabaseNote.fromMap(Map<String, dynamic> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] == 1) ? true : false;

  // Allow Dart to export note as a map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idColumn: id,
      userIdColumn: userId,
      textColumn: text,
      isSyncedWithCloudColumn: isSyncedWithCloud
    };
  }

  // Allow note to be printed/logged
  @override
  String toString() {
    return 'Note{id: $id, userId: $userId, isSyncedWithCloud: $isSyncedWithCloud, text: $text }';
  }

  // Allow for a note to be compared to another note
  @override
  bool operator ==(covariant DatabaseNote other) =>
      id == other.id && userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
