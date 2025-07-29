import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/blocs/quiz_page_bloc/quiz_page_bloc.dart';
import 'package:midnight_v1/classes/inference.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/pages/quiz_page/appbar_title.dart';
import 'package:midnight_v1/pages/quiz_page/identification_quiz_question_view.dart';
import 'package:midnight_v1/pages/quiz_page/multiple_choice_quiz_question_view.dart';
import 'dart:convert';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:async';

class QuizProgress {
  final Map<int, String> userAnswers; // question index -> answer
  final Map<int, bool> correctness; // question index -> correct/incorrect

  QuizProgress({required this.userAnswers, required this.correctness});

  Map<String, dynamic> toMap() => {
        'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'correctness': correctness.map((k, v) => MapEntry(k.toString(), v)),
      };

  factory QuizProgress.fromMap(Map<String, dynamic> map) => QuizProgress(
        userAnswers: Map<String, dynamic>.from(map['userAnswers'] ?? {})
            .entries
            .fold<Map<int, String>>({}, (acc, e) {
          acc[int.parse(e.key)] = e.value as String;
          return acc;
        }),
        correctness: Map<String, dynamic>.from(map['correctness'] ?? {})
            .entries
            .fold<Map<int, bool>>({}, (acc, e) {
          acc[int.parse(e.key)] = e.value as bool;
          return acc;
        }),
      );

  String toJson() => jsonEncode(toMap());

  factory QuizProgress.fromJson(String source) =>
      QuizProgress.fromMap(jsonDecode(source));
}

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quiz});

  final Quiz quiz;

  void _showGenerateDialog(BuildContext context, QuizPageLoadSuccess state) {
    final textController = TextEditingController();
    StreamController<String>? progressStreamController;
    bool isGenerating = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setter) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText:
                        "(Optional) Describe what new questions to generate...",
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isGenerating,
                ),
                const SizedBox(height: 16),
                StreamBuilder<String>(
                  stream: progressStreamController?.stream,
                  initialData: "",
                  builder: (context, snapshot) {
                    final progressText = snapshot.data ?? "";
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isGenerating
                            ? null
                            : () async {
                                setter(() {
                                  isGenerating = true;
                                });
                                try {
                                  final incorrectIndices = state.progress.correctness.entries
                                      .where((e) => e.value == false)
                                      .map((e) => e.key)
                                      .toList();
                                  final incorrectQuestions = incorrectIndices.map((i) {
                                    final q = state.quiz.questions[i];
                                    return {
                                      'index': i + 1,
                                      'question': q.question,
                                      if (q is MultipleChoiceQuizQuestion)
                                        'options': q.options.map((o) => o.text).toList(),
                                      'correctAnswer': q.answer,
                                      'userAnswer': state.progress.userAnswers[i],
                                    };
                                  }).toList();
                                  final progressSummary = {
                                    'incorrectQuestions': incorrectQuestions,
                                    'totalQuestions': state.quiz.questions.length,
                                    'correctCount': state.correctCount,
                                    'incorrectCount': state.incorrectCount,
                                    'unansweredCount': state.unansweredCount,
                                  };
                                  final userMessage = Content("user", [
                                    TextPart(
                                      "Here is my current quiz progress. Please focus on generating new questions that help me learn what I got wrong the most first.\n\nProgress (JSON):\n${jsonEncode(progressSummary)}${textController.text.trim().isNotEmpty ? "\n\nExtra instructions: ${textController.text.trim()}" : ""}",
                                    ),
                                  ]);
                                  final response = Inference.generateQuestions(
                                    userMessage,
                                  );
                                  progressStreamController = StreamController<String>.broadcast();
                                  response.progressText.listen((text) {
                                    if (progressStreamController != null && !progressStreamController!.isClosed) {
                                      progressStreamController!.add(text);
                                    }
                                  });
                                  final newQuestions = await response.questions;
                                  // This part needs to be handled by the BLoC now
                                  // setState(() {
                                  //   widget.quiz.addQuestions(newQuestions);
                                  //   _updateCounters();
                                  // });
                                  if (progressStreamController != null && !progressStreamController!.isClosed) {
                                    progressStreamController!.close();
                                  }
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  if (progressStreamController != null && !progressStreamController!.isClosed) {
                                    progressStreamController!.add(
                                      "Error: ${e.toString()}",
                                    );
                                    progressStreamController!.close();
                                  }
                                  setter(() {
                                    isGenerating = false;
                                  });
                                }
                              },
                        child: Text(
                          isGenerating
                              ? (progressText.isNotEmpty ? progressText : "Generating...")
                              : "Generate",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return BlocBuilder<QuizPageBloc, QuizPageState>(
      builder: (context, state) {
        if (state is QuizPageLoadInProgress) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is QuizPageLoadFailure) {
          return Scaffold(body: Center(child: Text(state.error)));
        } else if (state is QuizPageLoadSuccess) {
          return Scaffold(
            appBar: AppBar(
              title: AppbarTitle(quiz: quiz),
              actions: isMobile
                  ? null
                  : [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check, color: Colors.greenAccent),
                            const SizedBox(width: 4),
                            Text(
                              state.correctCount.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.close, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              state.incorrectCount.toString(),
                              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: IconButton.filledTonal(
                          onPressed: () => _showGenerateDialog(context, state),
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ],
            ),
            body: Stack(
              children: [
                Center(
                  child: ListView.builder(
                    itemCount: state.quiz.questions.length,
                    itemBuilder: (context, index) {
                      final question = state.quiz.questions[index];
                      final userAnswer = state.progress.userAnswers[index];
                      Widget widgetView;
                      if (question is MultipleChoiceQuizQuestion) {
                        widgetView = MultipleChoiceQuizQuestionView(
                          quizQuestion: question,
                          questionNumber: index,
                          userAnswer: userAnswer,
                          isCorrect: state.progress.correctness[index],
                          onAnswerSelected: (answer) {
                            context.read<QuizPageBloc>().add(AnswerSubmitted(index, answer));
                          },
                        );
                      } else {
                        widgetView = IdentificationQuizQuestionView(
                          quizQuestion: question,
                          questionNumber: index + 1,
                          userAnswer: userAnswer,
                          onAnswered: (answer, isCorrect) =>
                              context.read<QuizPageBloc>().add(AnswerSubmitted(index, answer)),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: isMobile ? 8.0 : 128.0,
                        ),
                        child: widgetView,
                      );
                    },
                  ),
                ),
                if (isMobile)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.greenAccent),
                          const SizedBox(width: 4),
                          Text(
                            state.correctCount.toString(),
                            style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.close, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            state.incorrectCount.toString(),
                            style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                          ),
                          const SizedBox(width: 16),
                          IconButton.filled(
                            onPressed: () => _showGenerateDialog(context, state),
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return const Scaffold(body: Center(child: Text("Something went wrong.")));
      },
    );
  }
}
