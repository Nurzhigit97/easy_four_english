import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/text_model.dart';
import '../models/speaking_answer_model.dart';
import '../models/writing_answer_model.dart';
import '../models/dictionary_model.dart';
import '../models/word_model.dart';

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

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
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

    await db.execute('''
      CREATE TABLE speaking_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        textId INTEGER NOT NULL,
        answer TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (textId) REFERENCES texts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE writing_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        textId INTEGER NOT NULL,
        writing TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (textId) REFERENCES texts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE dictionaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dictionaryId INTEGER NOT NULL,
        word TEXT NOT NULL,
        translation TEXT,
        context TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (dictionaryId) REFERENCES dictionaries (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS speaking_answers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          textId INTEGER NOT NULL,
          answer TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (textId) REFERENCES texts (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS writing_answers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          textId INTEGER NOT NULL,
          writing TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (textId) REFERENCES texts (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS dictionaries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dictionaryId INTEGER NOT NULL,
          word TEXT NOT NULL,
          translation TEXT,
          context TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (dictionaryId) REFERENCES dictionaries (id) ON DELETE CASCADE
        )
      ''');
    }
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

  // Speaking Answers
  Future<int> insertSpeakingAnswer(SpeakingAnswerModel answer) async {
    final db = await database;
    return await db.insert('speaking_answers', answer.toMap());
  }

  Future<List<SpeakingAnswerModel>> getSpeakingAnswersByTextId(
    int textId,
  ) async {
    final db = await database;
    final result = await db.query(
      'speaking_answers',
      where: 'textId = ?',
      whereArgs: [textId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => SpeakingAnswerModel.fromMap(map)).toList();
  }

  Future<int> deleteSpeakingAnswer(int id) async {
    final db = await database;
    return await db.delete(
      'speaking_answers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Writing Answers
  Future<int> insertWritingAnswer(WritingAnswerModel answer) async {
    final db = await database;
    return await db.insert('writing_answers', answer.toMap());
  }

  Future<List<WritingAnswerModel>> getWritingAnswersByTextId(int textId) async {
    final db = await database;
    final result = await db.query(
      'writing_answers',
      where: 'textId = ?',
      whereArgs: [textId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => WritingAnswerModel.fromMap(map)).toList();
  }

  Future<int> deleteWritingAnswer(int id) async {
    final db = await database;
    return await db.delete('writing_answers', where: 'id = ?', whereArgs: [id]);
  }

  // Dictionaries
  Future<int> insertDictionary(DictionaryModel dictionary) async {
    final db = await database;
    return await db.insert('dictionaries', dictionary.toMap());
  }

  Future<List<DictionaryModel>> getAllDictionaries() async {
    final db = await database;
    final result = await db.query('dictionaries', orderBy: 'createdAt DESC');
    return result.map((map) => DictionaryModel.fromMap(map)).toList();
  }

  Future<DictionaryModel?> getDictionaryById(int id) async {
    final db = await database;
    final result = await db.query(
      'dictionaries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DictionaryModel.fromMap(result.first);
  }

  Future<DictionaryModel?> getDictionaryByTitle(String title) async {
    final db = await database;
    final result = await db.query(
      'dictionaries',
      where: 'title = ?',
      whereArgs: [title],
    );
    if (result.isEmpty) return null;
    return DictionaryModel.fromMap(result.first);
  }

  Future<int> updateDictionary(DictionaryModel dictionary) async {
    final db = await database;
    return await db.update(
      'dictionaries',
      dictionary.toMap(),
      where: 'id = ?',
      whereArgs: [dictionary.id],
    );
  }

  Future<int> deleteDictionary(int id) async {
    final db = await database;
    return await db.delete('dictionaries', where: 'id = ?', whereArgs: [id]);
  }

  // Words
  Future<int> insertWord(WordModel word) async {
    final db = await database;
    return await db.insert('words', word.toMap());
  }

  Future<List<WordModel>> getWordsByDictionaryId(int dictionaryId) async {
    final db = await database;
    final result = await db.query(
      'words',
      where: 'dictionaryId = ?',
      whereArgs: [dictionaryId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => WordModel.fromMap(map)).toList();
  }

  Future<int> updateWord(WordModel word) async {
    final db = await database;
    return await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertWords(List<WordModel> words) async {
    final db = await database;
    final batch = db.batch();
    for (final word in words) {
      batch.insert('words', word.toMap());
    }
    await batch.commit(noResult: true);
    return words.length;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
