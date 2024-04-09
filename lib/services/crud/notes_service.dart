// Note: This file contains the code for the CRUD operations on the notes table

import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:mynotes/services/crud/database_note.dart';
import 'package:mynotes/services/crud/database_user.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;

// Note service: CRUD service class for our local database which stores notes &
// users
class NoteService {
  List<DatabaseNote> _notes = [];

  // the database
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
        isSyncedWithCloudColumn: 0,
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

// All these variables are used directly by the note_service to CRUD

// database related file and table names
// name of database
const String databaseName = 'notes.db';
// name of user table in database
const String userTable = 'user';
// name of note table in database
const String noteTable = 'note';

// database related column names
// name of id column in user & note tables
const String idColumn = 'id';
// name of email column in user table
const String emailColumn = 'email';
// name of userId column in note table
const String userIdColumn = 'user_id';
// name of text column in note table
const String textColumn = 'text';
// name of isSyncedWithCloud column in note table
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
