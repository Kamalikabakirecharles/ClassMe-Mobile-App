import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuizDatabaseHelper {
  static Database? _database;
  static const String dbName = 'quiz.db';

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null, initialize it
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // Create tables and schema here
    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        option1 TEXT,
        option2 TEXT,
        option3 TEXT,
        option4 TEXT,
        correctOption TEXT
      )
    ''');

    // Insert quiz questions data here
    // Loop through your Firebase quiz data and insert into SQLite
  }
}

Future<List<Map<String, dynamic>>> getOfflineQuizData() async {
  // Open SQLite database
  Database db = await QuizDatabaseHelper().database;

  // Fetch quiz questions from SQLite
  List<Map<String, dynamic>> questions = await db.query('questions');

  return questions;
}

Future<void> copyDataToSQLite() async {
  // Fetch quiz data from Firebase
  QuerySnapshot<Map<String, dynamic>> quizData =
      await FirebaseFirestore.instance.collection('quizzes').get();

  // Open SQLite database
  Database db = await QuizDatabaseHelper().database;

  // Loop through Firebase quiz data and insert into SQLite
  quizData.docs.forEach((quizDoc) async {
    await db.insert(
      'questions',
      {
        'question': quizDoc['question'],
        'option1': quizDoc['option1'],
        'option2': quizDoc['option2'],
        'option3': quizDoc['option3'],
        'option4': quizDoc['option4'],
        'correctOption': quizDoc['correctOption'],
      },
    );
  });
}
