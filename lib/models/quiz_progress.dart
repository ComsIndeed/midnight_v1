
import 'dart:convert';

class QuizProgress {
  final Map<int, String> userAnswers; // question index -> answer
  final Map<int, bool> correctness; // question index -> correct/incorrect

  QuizProgress({required this.userAnswers, required this.correctness});

  Map<String, dynamic> toMap() => {
    'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
    'correctness': correctness.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory QuizProgress.fromMap(Map<String, dynamic> map) => QuizProgress(
    userAnswers: Map<String, dynamic>.from(map['userAnswers'] ?? {}).entries
        .fold<Map<int, String>>({}, (acc, e) {
          acc[int.parse(e.key)] = e.value as String;
          return acc;
        }),
    correctness: Map<String, dynamic>.from(map['correctness'] ?? {}).entries
        .fold<Map<int, bool>>({}, (acc, e) {
          acc[int.parse(e.key)] = e.value as bool;
          return acc;
        }),
  );

  String toJson() => jsonEncode(toMap());

  factory QuizProgress.fromJson(String source) =>
      QuizProgress.fromMap(jsonDecode(source));
}
