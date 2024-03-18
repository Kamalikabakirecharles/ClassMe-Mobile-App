import 'package:ClassMe/services/database.dart';

class SyncService {
  final DatabaseService databaseService;

  SyncService({required this.databaseService});

  // Synchronize data from Firebase Firestore to SQLite
  void syncFromFirestoreToSQLite() {
    databaseService.getQuizData().listen((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        Map<String, dynamic> quizData = doc.data() as Map<String, dynamic>;
        await databaseService.dbHelper.insertOrUpdateQuiz(quizData);
      });
    });
  }

  // Synchronize data from SQLite to Firebase Firestore
  void syncFromSQLiteToFirestore() {
    databaseService.dbHelper.getQuizData().then((quizDataList) {
      quizDataList.forEach((quizData) {
        // Here, you need to provide both quizData and quizId arguments
        String quizId = quizData['id'];
        databaseService.addQuizData(quizData, quizId);
      });
    });
  }
}
