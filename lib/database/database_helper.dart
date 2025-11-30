import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/text_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('texts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE texts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Get all texts
  Future<List<TextModel>> getAllTexts() async {
    final db = await database;
    final result = await db.query('texts', orderBy: 'createdAt DESC');
    return result.map((map) => TextModel.fromMap(map)).toList();
  }

  // Get text by id
  Future<TextModel?> getTextById(int id) async {
    final db = await database;
    final result = await db.query('texts', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return TextModel.fromMap(result.first);
  }

  // Insert text
  Future<int> insertText(TextModel text) async {
    final db = await database;
    return await db.insert('texts', text.toMap());
  }

  // Update text
  Future<int> updateText(TextModel text) async {
    final db = await database;
    return await db.update(
      'texts',
      text.toMap(),
      where: 'id = ?',
      whereArgs: [text.id],
    );
  }

  // Delete text
  Future<int> deleteText(int id) async {
    final db = await database;
    return await db.delete('texts', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
