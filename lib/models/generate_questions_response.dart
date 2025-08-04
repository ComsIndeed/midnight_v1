import 'dart:async';

import 'package:midnight_v1/models/quiz.dart';

class GenerateQuestionsResponse {
  final Future<List<QuizQuestion>> questions;
  final Stream<String> progressText;

  GenerateQuestionsResponse({
    required this.questions,
    required this.progressText,
  });
}
