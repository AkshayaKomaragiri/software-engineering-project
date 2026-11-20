import 'dart:io';

import 'package:flutter_swe_demo/main.dart' show DatabaseHelper;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

void main() {
  test('T03 prototype: a saved note survives reopening SQLite', () async {
    const userId = 't03-persistence-test';
    const content = 'Note saved before reopening';
    final directory = await Directory.systemTemp.createTemp('rep-rank-t03-');
    final databasePath = p.join(directory.path, 'notes_$userId.db');
    addTearDown(() => directory.delete());

    ffi.sqfliteFfiInit();
    final originalFactory = ffi.databaseFactoryOrNull;
    final testFactory = ffi.createDatabaseFactoryFfi();
    await testFactory.setDatabasesPath(directory.path);
    addTearDown(() => testFactory.deleteDatabase(databasePath));
    ffi.databaseFactoryOrNull = testFactory;
    addTearDown(() => ffi.databaseFactoryOrNull = originalFactory);

    final writer = DatabaseHelper(userId);
    addTearDown(writer.close);
    final savedId = await writer.insertNote(content);
    final originalConnection = await writer.database;

    await writer.close();
    expect(originalConnection.isOpen, isFalse);
    expect(await File(databasePath).exists(), isTrue);

    final reader = DatabaseHelper(userId);
    addTearDown(reader.close);
    final notes = await reader.fetchNotes();

    expect(notes, hasLength(1));
    expect(notes.single['id'], savedId);
    expect(notes.single['content'], content);
  });
}
