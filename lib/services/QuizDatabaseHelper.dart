import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final _databaseName = 'quiz.db';
  static final _databaseVersion = 1;

  static final tableQuiz = 'quiz';
  static final tableQuestion = 'question';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnDescription = 'description';
  static final columnImgUrl = 'ImgUrl';
  static final columnOption1 = 'option1';
  static final columnOption2 = 'option2';
  static final columnOption3 = 'option3';
  static final columnOption4 = 'option4';
  static final columnQuestion = 'question';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableQuiz (
      $columnId TEXT PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnImgUrl TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE $tableQuestion (
      $columnId TEXT PRIMARY KEY,
      $columnQuestion TEXT NOT NULL,
      $columnOption1 TEXT NOT NULL,
      $columnOption2 TEXT NOT NULL,
      $columnOption3 TEXT NOT NULL,
      $columnOption4 TEXT NOT NULL,
      FOREIGN KEY ($columnId) REFERENCES $tableQuiz($columnId) ON DELETE CASCADE
    )
  ''');
  }

  Future<int> insertQuiz(Map<String, dynamic> quizData) async {
    Database db = await database;
    return await db.insert(tableQuiz, quizData);
  }

  Future<int> insertQuestion(Map<String, dynamic> questionData) async {
    Database db = await database;
    return await db.insert(tableQuestion, questionData);
  }

  Future<int> updateQuiz(
      String quizId, Map<String, dynamic> updatedData) async {
    Database db = await database;
    return await db.update(
      tableQuiz,
      updatedData,
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> updateQuestion(String questionId,
      Map<String, dynamic> updatedData, String quizId) async {
    Database db = await database;
    // Update question with quizId
    return await db.update(
      tableQuestion,
      updatedData,
      where: '$columnId = ? AND quizId = ?',
      whereArgs: [questionId, quizId],
    );
  }

  Future<int> deleteQuiz(String quizId) async {
    Database db = await database;
    return await db.delete(
      tableQuiz,
      where: '$columnId = ?',
      whereArgs: [quizId],
    );
  }

  Future<int> deleteQuestion(String questionId, String quizId) async {
    Database db = await database;
    // Delete question with quizId
    return await db.delete(
      tableQuestion,
      where: '$columnId = ? AND quizId = ?',
      whereArgs: [questionId, quizId],
    );
  }

  // In DatabaseHelper class
  Future<int> insertOrUpdateQuiz(Map<String, dynamic> quizData) async {
    Database db = await database;
    return await db.insert(tableQuiz, quizData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getQuizData() async {
    Database db = await database;
    return await db.query(tableQuiz);
  }
}
