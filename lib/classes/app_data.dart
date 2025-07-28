import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/generate_quiz_response.dart';
import 'package:midnight_v1/classes/inference.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData with ChangeNotifier {
  Future<void> clearAllQuizzes() async {
    quizzes.clear();
    await saveQuizzes();
    notifyListeners();
  }

  final SharedPreferences prefs;
  AppData(this.prefs) {
    _loadQuizzes();
  }

  List<Quiz> quizzes = [];

  static const String quizzesKey = 'quizzes_list';

  Future<void> _loadQuizzes() async {
    final quizJsons = prefs.getStringList(quizzesKey) ?? [];
    quizzes = quizJsons.map((q) => Quiz.fromJson(q)).toList();
    notifyListeners();
  }

  Future<void> saveQuizzes() async {
    final quizJsons = quizzes.map((q) => q.toJson()).toList();
    await prefs.setStringList(quizzesKey, quizJsons);
  }

  GenerateQuizResponse generateQuiz(Content userMessage) {
    final generateQuizResponse = Inference.generateQuiz(userMessage, []);
    generateQuizResponse.quiz.then((quiz) {
      quizzes.add(quiz);
      saveQuizzes();
      notifyListeners();
    });
    return generateQuizResponse;
  }

  Future<void> deleteQuiz(Quiz quiz) async {
    quizzes.remove(quiz);
    await saveQuizzes();
    notifyListeners();
  }

  Future<void> renameQuiz(Quiz quiz, String newTitle) async {
    final idx = quizzes.indexOf(quiz);
    if (idx != -1) {
      quizzes[idx] = Quiz(title: newTitle, questions: quiz.questions);
      await saveQuizzes();
      notifyListeners();
    }
  }

  Future<void> regenerateQuiz(Quiz quiz) async {
    // Optionally, regenerate using the original prompt if stored
    // For now, just remove and generate a new quiz
    await deleteQuiz(quiz);
    // You may want to pass the original prompt here
    // final newQuiz = await generateQuiz(...);
    notifyListeners();
  }
}
