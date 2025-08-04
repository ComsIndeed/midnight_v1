import 'dart:async';
import 'dart:convert';
import 'package:midnight_v1/classes/generate_questions_response.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/app_prefs.dart';
import 'package:midnight_v1/classes/generate_quiz_response.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/classes/embedding.dart';
import 'package:midnight_v1/classes/source.dart';
import 'package:midnight_v1/classes/utilities/trim_code_block.dart';

class Inference {
  static const _questionsGenerationPrompt = '''
You are a quiz question generation assistant. Your task is to generate a list of quiz questions in valid JSON format.

Respond ONLY with a JSON array of question objects. Each object must have:
- `question`: string
- `options`: array of strings (for multiple choice)
- `answer`: string (must be one of the options)

Example:
[
  {
    "question": "What is the capital of France?",
    "options": ["Berlin", "Madrid", "Paris", "Rome"],
    "answer": "Paris"
  },
  {
    "question": "What is 2 + 2?",
    "options": ["3", "4", "5", "6"],
    "answer": "4"
  }
]

Do not include any other text, explanations, or formatting outside the JSON array.
''';

  static GenerateQuestionsResponse generateQuestions(Content userMessage) {
    final model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: AppPrefs.apiKey,
      systemInstruction: Content.system(_questionsGenerationPrompt),
      tools: [Tool(googleSearch: GoogleSearch())],
    );

    final responses = model.generateContentStream([
      userMessage,
    ]).asBroadcastStream();

    int characters = 0;
    final progressStreamController = StreamController<String>.broadcast();
    responses.map((c) => c.text ?? "").listen((chunk) {
      characters += chunk.length;
      progressStreamController.add("[Generating: $characters characters]");
    });

    final questionsCompleter = Completer<List<QuizQuestion>>();
    responses.map((c) => c.text ?? "").join().then((response) async {
      final questionsJson = trimCodeBlock(response);
      final List<dynamic> arr = jsonDecode(questionsJson);
      final questions = arr.map((q) {
        if (q is Map<String, dynamic> && q.containsKey('options')) {
          return MultipleChoiceQuizQuestion.fromMap(q);
        } else {
          return QuizQuestion.fromMap(q);
        }
      }).toList();
      // Optionally embed questions here if needed
      questionsCompleter.complete(questions.cast<QuizQuestion>());
      progressStreamController.add("[Done]");
      await Future.delayed(Duration(seconds: 1));
      progressStreamController.add("");
      progressStreamController.close();
    });

    return GenerateQuestionsResponse(
      questions: questionsCompleter.future,
      progressText: progressStreamController.stream,
    );
  }

  static const _quizGenerationPrompt = '''
You are a quiz generation assistant. Your task is to generate a quiz based on the user's prompt. The quiz must be in a valid JSON format.

The JSON object must have two top-level keys: `title` (a string for the quiz title) and `questions` (a list of question objects).

Each question object in the `questions` list must be a multiple-choice question and have the following keys:
- `question`: A string containing the question text.
- `options`: A list of strings representing the multiple-choice options.
- `answer`: A string containing the correct answer. The value of `answer` must be one of the strings from the `options` list.

Here is an example of the required JSON format:

```json
{
  "title": "Example Quiz",
  "questions": [
    {
      "question": "What is the capital of France?",
      "options": ["Berlin", "Madrid", "Paris", "Rome"],
      "answer": "Paris"
    },
    {
      "question": "What is 2 + 2?",
      "options": ["3", "4", "5", "6"],
      "answer": "4"
    }
  ]
}
```

Ensure the generated JSON is well-formed and adheres strictly to this structure. Do not include any other text or explanations outside of the JSON object.

Notes:
- If the requested number of questions is not specified, default to 20 questions.
- Do not generate more than 30 questions at once. Simply generate at the max of 30 if the request goes above this limit.
''';

  static GenerateQuizResponse generateQuiz(
    Content userMessage,
    List<Source> sources,
  ) {
    final model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: AppPrefs.apiKey,
      systemInstruction: Content.system(_quizGenerationPrompt),
      tools: [Tool(googleSearch: GoogleSearch())],
    );

    final responses = model.generateContentStream([
      userMessage,
    ]).asBroadcastStream();

    int characters = 0;
    final progressStreamController = StreamController<String>.broadcast();
    responses.map((c) => c.text ?? "").listen((chunk) {
      characters += chunk.length;
      progressStreamController.add(
        "(1/2) [Generating: $characters characters]",
      );
    });

    final quizCompleter = Completer<Quiz>();
    responses.map((c) => c.text ?? "").join().then((response) async {
      try {
        final quizJson = trimCodeBlock(response);
        if (quizJson.trim().isEmpty) throw Exception("No quiz generated");
        final quiz = Quiz.fromJson(quizJson);

        // Only embed if enabled
        if (AppPrefs.embeddingEnabled) {
          progressStreamController.add("(2/2) [Embedding content]");
          for (final question in quiz.questions) {
            if (question is MultipleChoiceQuizQuestion) {
              await question.populateEmbeddings();
            } else {
              final contents = [
                Content.text(question.question),
                Content.text(question.answer),
              ];
              final response = await Embedding.model.batchEmbedContents(
                contents
                    .map(
                      (c) => EmbedContentRequest(
                        c,
                        taskType: TaskType.semanticSimilarity,
                      ),
                    )
                    .toList(),
              );
              question.questionEmbedding = response.embeddings[0].values;
              question.embeddings = response.embeddings[1].values;
            }
          }
        }
        quizCompleter.complete(quiz);
        progressStreamController.add("[Done]");
      } catch (e) {
        quizCompleter.completeError(e);
        progressStreamController.add("[Error: ${e.toString()}]");
      } finally {
        await Future.delayed(Duration(seconds: 1));
        progressStreamController.add("");
        progressStreamController.close();
      }
    });

    return GenerateQuizResponse(
      quiz: quizCompleter.future,
      progressText: progressStreamController.stream,
    );
  }
}
