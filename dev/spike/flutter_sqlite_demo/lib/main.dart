import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite Spike',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SqliteSpikePage(),
    );
  }
}

// Simple Database Helper class to manage SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertNote(String content) async {
    final db = await instance.database;
    final data = {
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    };
    return await db.insert('notes', data);
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await instance.database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

class SqliteSpikePage extends StatefulWidget {
  const SqliteSpikePage({super.key});

  @override
  State<SqliteSpikePage> createState() => _SqliteSpikePageState();
}

class _SqliteSpikePageState extends State<SqliteSpikePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await DatabaseHelper.instance.fetchNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  void _saveNote() async {
    if (_controller.text.trim().isEmpty) return;

    await DatabaseHelper.instance.insertNote(_controller.text);
    _controller.clear();
    _refreshNotes();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved to SQLite successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SQLite Spike'),
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
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              label: const Text('Save to SQLite'),
            ),
            const Divider(height: 30),
            const Text(
              'Stored Records:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notes.isEmpty
                      ? const Center(child: Text('No data found in SQLite yet.'))
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            return Card(
                              child: ListTile(
                                title: Text(note['content']),
                                subtitle: Text('Saved at: ${note['createdAt']}'),
                                trailing: Text('#${note['id']}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}