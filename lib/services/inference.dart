import 'dart:async';
import 'dart:convert';
import 'package:midnight_v1/models/generate_questions_response.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/services/app_prefs.dart';
import 'package:midnight_v1/models/generate_quiz_response.dart';
import 'package:midnight_v1/models/quiz.dart';
import 'package:midnight_v1/services/embedding.dart';
import 'package:midnight_v1/models/source.dart';
import 'package:midnight_v1/utils/prompts.dart';
import 'package:midnight_v1/utils/trim_code_block.dart';

class Inference {
  

  static GenerateQuestionsResponse generateQuestions(Content userMessage) {
    final model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: AppPrefs.instance.apiKey,
      systemInstruction: Content.system(questionsGenerationPrompt),
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

  

  static GenerateQuizResponse generateQuiz(
    Content userMessage,
    List<Source> sources,
  ) {
    final model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: AppPrefs.instance.apiKey,
      systemInstruction: Content.system(quizGenerationPrompt),
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
        if (AppPrefs.instance.embeddingEnabled) {
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
