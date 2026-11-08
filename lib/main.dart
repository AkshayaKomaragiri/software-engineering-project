import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    ffi.sqfliteFfiInit();
    databaseFactory = ffi.databaseFactoryFfi;
  }

  await Supabase.initialize(
    url: 'https://unmhsneoyfcwndxgksrr.supabase.co',
    publishableKey: 'sb_publishable_W1fPsmjFCOPJkldCoqcUCQ_AM-hCnmv',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite Spike',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
    );
  }
}

// Switch between the authentication page and the user's notes page.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = supabase.auth.currentUser;
    _authSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        if (!mounted) return;
        setState(() {
          _user = data.session?.user;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Authentication stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const AuthPage();
    }
    return SqliteSpikePage(key: ValueKey(user.id), userId: user.id);
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  bool _createAccount = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter an email address and password.');
      return;
    }

    setState(() => _busy = true);
    try {
      if (_createAccount) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (!mounted) return;
        if (response.session == null) {
          _showMessage('Account created. Check your email to confirm it, then sign in.');
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) _showMessage('Unable to authenticate: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_createAccount ? 'Create Account' : 'Sign In')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) {
                    if (!_busy) _submit();
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_busy ? 'Please wait...' : (_createAccount ? 'Create Account' : 'Sign In')),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _createAccount = !_createAccount),
                  child: Text(_createAccount ? 'Already have an account? Sign in' : 'Need an account? Create one'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Each authenticated user gets a different file on this device.
// Do not use this file-name separation as a substitute for device encryption.

class DatabaseHelper {
  DatabaseHelper(this.userId);

  final String userId;
  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDB('notes_$userId.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }
  Future<int> insertCloudNotes(List<Map<String, dynamic>> cloudNotes,) async {
    final db = await database;
    int inserted = 0;

    await db.transaction((txn) async {
      for (final note in cloudNotes) {
        await txn.rawInsert(
          '''
          INSERT OR IGNORE INTO notes
            (id, content, createdAt, synced)
          VALUES (?, ?, ?, ?)
          ''',
          [
            note['id'],
            note['content'],
            note['created_at'],
            1,
          ],
        );

        final result = await txn.rawQuery(
          'SELECT changes() AS inserted',
        );

        inserted += result.first['inserted'] as int;

        
      }
    });

    return inserted;
  }



  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Create the new table.
      await db.execute('''
        CREATE TABLE notes_new (
          id TEXT PRIMARY KEY,
          content TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Retrieve entries from the original table.
      final oldNotes = await db.query('notes');

      // Preserve each note and assign it a UUID.
      for (final note in oldNotes) {
        await db.insert('notes_new', {
          'id': const Uuid().v4(),
          'content': note['content'],
          'createdAt': note['createdAt'],
          'synced': 0,
        });
      }

      // Replace the original table.
      await db.execute('DROP TABLE notes');
      await db.execute(
        'ALTER TABLE notes_new RENAME TO notes',
      );
    }
  }

  Future<String> insertNote(String content) async {
    final db = await database;
    final id = const Uuid().v4();

    await db.insert('notes', {
      'id': id,
      'content': content,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'synced': 0,
    });

    return id;
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await database;

    return await db.query(
      'notes',
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> close() async {
    final db = _database;
    _database = null;

    if (db != null && db.isOpen) {
      await db.close();
    }
  }
  Future<List<Map<String, dynamic>>> fetchUnsyncedNotes() async {
    final db = await database;

    return await db.query(
      'notes',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }
  Future<void> markNoteSynced(String noteId) async {
    final db = await database;

    await db.update(
      'notes',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}





class SqliteSpikePage extends StatefulWidget {
  const SqliteSpikePage({super.key, required this.userId});
  final String userId;

  @override
  State<SqliteSpikePage> createState() => _SqliteSpikePageState();
}

class _SqliteSpikePageState extends State<SqliteSpikePage> {
  final TextEditingController _controller = TextEditingController();
  late final DatabaseHelper _db;
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  bool _saving = false;
  bool _loggingOut = false;
  bool _syncing = false;
  bool _downloading = false;
  //code used for testing 
  /*Future<void> _testRLSInsert() async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      debugPrint('TEST ERROR: No authenticated user.');
      return;
    }

    debugPrint('Authenticated user: ${currentUser.id}');

    try {
      await supabase.from('notes').insert({
        'id': const Uuid().v4(),
        'user_id': '667e053c-6397-4ab0-834e-bc7f560621ad',
        'content': 'Unauthorized insert test',
      });

      debugPrint('TEST FAILED: Unauthorized insert was allowed.');
    } catch (error) {
      debugPrint('Insert rejected: $error');

      if (error is PostgrestException && error.code == '42501') {
        debugPrint('TEST PASSED: RLS rejected the unauthorized insert.');
      } else {
        debugPrint('TEST INCONCLUSIVE: Investigate the error.');
      }
    }
  }*/

  @override
  void initState() {
    super.initState();
    _db = DatabaseHelper(widget.userId);
    _downloadNotes();
  }

  Future<void> _refreshNotes() async {
    try {
      final data = await _db.fetchNotes();
      if (!mounted) return;
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not load notes: $error');
    }
  }
  
  Future<void> _downloadNotes() async {
    if (_downloading) return;

    setState(() {
      _downloading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null || user.id != widget.userId) {
        throw Exception('No matching authenticated user.');
      }

      final cloudNotes = await supabase
          .from('notes')
          .select('id, user_id, content, created_at')
          .eq('user_id', user.id);

      if (supabase.auth.currentUser?.id != widget.userId) {
        throw Exception('User changed during download.');
      }

      final inserted = await _db.insertCloudNotes(
        cloudNotes,
      );

      if (mounted) {
        _showMessage(
          'Download complete: $inserted new notes added.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Download failed: $error');
      }
    } finally {
      await _refreshNotes();

      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }


  Future<void> _saveNote() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _saving || _loggingOut || _downloading) return;
    setState(() => _saving = true);
    try {
      await _db.insertNote(content);
      _controller.clear();
      await _refreshNotes();
      if (mounted) _showMessage('Note saved to this account\'s SQLite database.');
    } catch (error) {
      if (mounted) _showMessage('Could not save note: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logOut() async {
    if (_saving || _loggingOut || _downloading) return;
    setState(() => _loggingOut = true);
    try {
      await supabase.auth.signOut();
    } catch (error) {
      if (mounted) {
        _showMessage('Could not log out: $error');
        setState(() => _loggingOut = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildNotesDisplay() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_notes.isEmpty) {
      return const Center(child: Text('No data found in SQLite yet.'));
    } else {
      return ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            child: ListTile(
              title: Text(note['content'] as String),
              subtitle: Text('Saved at: ${note['createdAt']}'),
              trailing: Text(
                  note['synced'] == 1 ? 'Synced' : 'Local',
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(_db.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SQLite Spike'),
        actions: [
          TextButton(
            onPressed: (_saving || _syncing || _downloading || _loggingOut) ? null : _logOut,
            child: const Text('Log Out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter something to store',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_saving || _syncing || _downloading|| _loggingOut) ? null : _saveNote,
              icon: const Icon(Icons.save),
              label: const Text('Save to SQLite'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_syncing || _saving || _downloading || _loggingOut) ? null : _syncNotes,
              icon: const Icon(Icons.cloud_upload),
              label: Text(
                _syncing ? 'Synchronizing...' : 'Finish (Sync to Supabase)',
              ),
            ),
            /*const SizedBox(height: 12),
            ElevatedButton(onPressed: _testRLSInsert, child: const Text('Test RLS Insert')),*/
            const Divider(height: 30),
            const Text('Stored Records:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _buildNotesDisplay()),
          ],
        ),
      ),
    );
  }

  
  Future<void> _syncNotes() async {
    if (_syncing || _saving || _loggingOut || _downloading) return;

    setState(() {
      _syncing = true;
    });

    int uploaded = 0;

    try {
      final user = supabase.auth.currentUser;

      if (user == null || user.id != widget.userId) {
        throw Exception('No matching authenticated user.');
      }

      final unsyncedNotes = await _db.fetchUnsyncedNotes();

      for (final note in unsyncedNotes) {
        if (supabase.auth.currentUser?.id != widget.userId) {
          throw Exception('Authenticated user changed during sync.');
        }

        await supabase.from('notes').upsert(
          {
            'id': note['id'],
            'user_id': user.id,
            'content': note['content'],
            'created_at': note['createdAt'],
          },
          onConflict: 'id',
          ignoreDuplicates: true,
        );

        await _db.markNoteSynced(note['id'] as String);
        uploaded++;
      }

      await _refreshNotes();

      if (mounted) {
        _showMessage('Synchronization complete: $uploaded notes uploaded.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Synchronization failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

}
