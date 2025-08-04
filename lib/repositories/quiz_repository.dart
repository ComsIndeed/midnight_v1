import 'package:midnight_v1/models/quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizRepository {
  final SharedPreferences prefs;

  QuizRepository(this.prefs);

  static const String quizzesKey = 'quizzes_list';

  Future<List<Quiz>> loadQuizzes() async {
    final quizJsons = prefs.getStringList(quizzesKey) ?? [];
    return quizJsons.map((q) => Quiz.fromJson(q)).toList();
  }

  Future<void> saveQuizzes(List<Quiz> quizzes) async {
    final quizJsons = quizzes.map((q) => q.toJson()).toList();
    await prefs.setStringList(quizzesKey, quizJsons);
  }

  
}
