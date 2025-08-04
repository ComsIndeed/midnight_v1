import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/services/embedding.dart';
import 'package:midnight_v1/models/source.dart';
import 'package:uuid/uuid.dart';

class Quiz {
  void addQuestions(List<QuizQuestion> newQuestions) {
    questions.addAll(newQuestions);
  }

  final String id;
  final String title;
  final List<QuizQuestion> questions;
  final String generationPrompt;
  final List<Source> sources;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    this.generationPrompt = "",
    this.sources = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'generationPrompt': generationPrompt,
      'sources': sources.map((s) => s.toMap()).toList(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? Quiz.generateUuid(),
      title: map['title'],
      questions: (map['questions'] as List).map((q) {
        if (q is Map<String, dynamic> && q.containsKey('options')) {
          return MultipleChoiceQuizQuestion.fromMap(q);
        } else {
          return QuizQuestion.fromMap(q);
        }
      }).toList(),
      generationPrompt: map['generationPrompt'] ?? "",
      sources:
          (map['sources'] as List?)?.map((s) => Source.fromMap(s)).toList() ??
          [],
    );
  }
  static String generateUuid() => const Uuid().v4();

  String toJson() => jsonEncode(toMap());

  factory Quiz.fromJson(String source) => Quiz.fromMap(jsonDecode(source));
}

class QuizOption {
  final String text;
  List<double> embedding;
  List<double> embeddings; // Alias for clarity and future extensibility

  QuizOption({
    required this.text,
    List<double>? embedding,
    List<double>? embeddings,
  }) : embedding = embedding ?? <double>[],
       embeddings = embeddings ?? <double>[];

  Map<String, dynamic> toMap() => {
    'text': text,
    'embedding': embedding,
    'embeddings': embeddings,
  };

  factory QuizOption.fromMap(Map<String, dynamic> map) => QuizOption(
    text: map['text'] ?? '',
    embedding: map['embedding'] != null
        ? List<double>.from(map['embedding'])
        : <double>[],
    embeddings: map['embeddings'] != null
        ? List<double>.from(map['embeddings'])
        : <double>[],
  );
}

class QuizQuestion {
  final String question;
  final String answer;
  List<double> questionEmbedding;
  List<double> embeddings; // Alias for clarity and future extensibility

  QuizQuestion({
    required this.question,
    required this.answer,
    List<double>? questionEmbedding,
    List<double>? embeddings,
  }) : questionEmbedding = questionEmbedding ?? <double>[],
       embeddings = embeddings ?? <double>[];

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'questionEmbedding': questionEmbedding,
      'embeddings': embeddings,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'],
      answer: map['answer'],
      questionEmbedding: map['questionEmbedding'] != null
          ? List<double>.from(map['questionEmbedding'])
          : <double>[],
      embeddings: map['embeddings'] != null
          ? List<double>.from(map['embeddings'])
          : <double>[],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory QuizQuestion.fromJson(String source) =>
      QuizQuestion.fromMap(jsonDecode(source));
}

class MultipleChoiceQuizQuestion extends QuizQuestion {
  final List<QuizOption> options;

  MultipleChoiceQuizQuestion({
    required super.question,
    required super.answer,
    required List<QuizOption> options,
    super.questionEmbedding,
  }) : options = options;

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['options'] = options.map((o) => o.toMap()).toList();
    return map;
  }

  factory MultipleChoiceQuizQuestion.fromMap(Map<String, dynamic> map) {
    return MultipleChoiceQuizQuestion(
      question: map['question'],
      answer: map['answer'],
      options: (map['options'] as List).map((o) {
        if (o is String) {
          return QuizOption(text: o);
        } else if (o is Map<String, dynamic>) {
          return QuizOption.fromMap(o);
        } else {
          throw Exception('Invalid option type: ${o.runtimeType}');
        }
      }).toList(),
      questionEmbedding: map['questionEmbedding'] != null
          ? List<double>.from(map['questionEmbedding'])
          : null,
    );
  }

  @override
  String toJson() => jsonEncode(toMap());

  factory MultipleChoiceQuizQuestion.fromJson(String source) =>
      MultipleChoiceQuizQuestion.fromMap(jsonDecode(source));

  /// Populates embeddings for the question and all options using Gemini embedding model.
  Future<void> populateEmbeddings() async {
    final contents = <Content>[
      Content.text(question),
      ...options.map((o) => Content.text(o.text)),
    ];
    final response = await Embedding.model.batchEmbedContents(
      contents
          .map(
            (c) =>
                EmbedContentRequest(c, taskType: TaskType.semanticSimilarity),
          )
          .toList(),
    );
    if (response.embeddings.length != contents.length) {
      throw Exception('Embedding response count mismatch');
    }
    // First embedding is for question
    questionEmbedding = response.embeddings[0].values;
    // Remaining embeddings are for options
    for (int i = 0; i < options.length; i++) {
      options[i].embedding = response.embeddings[i + 1].values;
    }
  }
}
