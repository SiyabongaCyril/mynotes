// Note: This file contains the code for the CRUD operations on the notes table

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;

// database related file and table names
const String databaseName = 'notes.db';
const String userTable = 'user';
const String noteTable = 'note';

// database related column names
const String idColumn = 'id';
const String emailColumn = 'email';
const String userIdColumn = 'user_id';
const String textColumn = 'text';
const String isSyncedWithCloudColumn = 'is_synced_with_cloud';

// database related queries
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
          "id"	INTEGER NOT NULL UNIQUE,
          "user_id"	INTEGER NOT NULL,
          "text"	TEXT,
          "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY("id" AUTOINCREMENT)
          );''';
const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
	        "id"	INTEGER NOT NULL UNIQUE,
	        "email"	TEXT NOT NULL UNIQUE,
	        PRIMARY KEY("id" AUTOINCREMENT)
          );''';

// Represents a single user
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

// Represents a single note
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

class NoteService {
  Database? _db;

  // Get the database if it is open
  Database get _getDatabaseOrThrow {
    if (_db == null) {
      throw DatabaseNotOpen();
    } else {
      return _db!;
    }
  }

  // Open the database
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpen();
    } else {
      try {
        // Get the path to the app's documents directory
        final documentsPath = await getApplicationDocumentsDirectory();

        // Construct the path to the database
        final databasePath = join(documentsPath.path, databaseName);

        // Open the database using the database path
        final database = await openDatabase(databasePath);

        // Store the database
        _db = database;

        // Create the user and note tables

        await database.execute(createUserTable);
        await database.execute(createNoteTable);
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocumentsDirectory();
      }
    }
  }

  // Close the database
  Future<void> close() async {
    if (_db == null) {
      throw DatabaseNotOpen();
    } else {
      await _db!.close();
      _db = null;
    }
  }

  // User methods: CRUD (except for updating the user)
  // Delete user with email
  Future<void> deleteUserByEmail({required String email}) async {
    // Get the database
    final db = _getDatabaseOrThrow;

    final deletedUsers = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedUsers != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // Create new user with email
  Future<DatabaseUser> createUserWithEmail({required String email}) async {
    final db = _getDatabaseOrThrow;

    final getUserWithEmail = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    if (getUserWithEmail.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      final userID = await db.insert(
        userTable,
        <String, dynamic>{emailColumn: email.toLowerCase()},
      );

      return Future.value(DatabaseUser(id: userID, email: email));
    }
  }

  // Get user with email
  Future<DatabaseUser> getUserWithEmail({required String email}) async {
    final db = _getDatabaseOrThrow;

    final user = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (user.isEmpty) {
      throw UserNotFound();
    } else {
      return Future.value(DatabaseUser.fromMap(user.first));
    }
  }

  // Note methods: CRUD
  // Create new note()
  Future<DatabaseNote> createNote(DatabaseUser owner) async {
    final db = _getDatabaseOrThrow;

    // getUserWith Email throws an exception if the user is not found
    final getUser = await getUserWithEmail(email: owner.email);

    const String text = '';

    if (getUser != owner) {
      throw UserNotFound();
    } else {
      final noteID = await db.insert(noteTable, <String, dynamic>{
        userIdColumn: owner.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1
      });

      return Future.value(DatabaseNote(
        id: noteID,
        userId: owner.id,
        text: text,
        isSyncedWithCloud: true,
      ));
    }
  }

  // Delete note
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow;

    final deletedNotes = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedNotes != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // Delete all notes
  Future<void> deleteAllNotes() async {
    final db = _getDatabaseOrThrow;

    await db.delete(noteTable);
  }

  // Get all notes
  Future<List<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow;

    // Get all rows from the note table
    final notes = await db.query(noteTable);

    // Convert the map of row to a list of DatabaseNotes
    List<DatabaseNote> databaseNotes =
        notes.map((e) => DatabaseNote.fromMap(e)).toList();

    return Future.value(databaseNotes);
  }

  // Fetch note
  Future<DatabaseNote> getNoteWithId({required int id}) async {
    final db = _getDatabaseOrThrow;

    final note = await db.query(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (note.isEmpty) {
      throw NoteNotFound();
    } else {
      return Future.value(DatabaseNote.fromMap(note.first));
    }
  }

  // Update Note
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    // Get note by id & throw exception if not found
    await getNoteWithId(id: note.id);

    //  Update the note
    final updatedNotesCount = await _getDatabaseOrThrow.update(
      noteTable,
      <String, dynamic>{
        textColumn: text,
        isSyncedWithCloudColumn: 1,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatedNotesCount != 1) {
      throw CouldNotUpdateNote();
    }

    return getNoteWithId(id: note.id);
  }
}
