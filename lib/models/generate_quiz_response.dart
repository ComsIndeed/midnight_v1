import 'package:midnight_v1/models/quiz.dart';

class GenerateQuizResponse {
  Future<Quiz> quiz;
  Stream<String> progressText;

  GenerateQuizResponse({required this.quiz, required this.progressText});
}
