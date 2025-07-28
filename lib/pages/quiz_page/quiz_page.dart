import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/inference.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/pages/quiz_page/appbar_title.dart';
import 'package:midnight_v1/pages/quiz_page/identification_quiz_question_view.dart';
import 'package:midnight_v1/pages/quiz_page/multiple_choice_quiz_question_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late QuizProgress progress;
  bool _loading = true;
  int correct = 0;
  int incorrect = 0;
  int unanswered = 0;
  late SharedPreferences prefs;

  String get progressKey => 'quiz_progress_${widget.quiz.title}';

  @override
  void initState() {
    super.initState();
    print("LOADING");
    _initAsync();
  }

  void _initAsync() async {
    await _loadPrefs();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadPrefs() async {
    print("RAN");
    prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(progressKey);
    print("SAVED: $saved");
    if (saved != null && saved.isNotEmpty) {
      final map = Map<String, dynamic>.from(
        (saved.isNotEmpty)
            ? (Map<String, dynamic>.from(
                await Future.value(_decodeJson(saved)),
              ))
            : {},
      );
      progress = QuizProgress.fromMap(map);
    } else {
      progress = QuizProgress(userAnswers: {}, correctness: {});
    }
    _updateCounters();
    print("FINAL: $progress");
  }

  Map<String, dynamic> _decodeJson(String source) {
    return source.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(source))
        : {};
  }

  void _updateCounters() {
    correct = progress.correctness.values.where((v) => v).length;
    incorrect = progress.correctness.values.where((v) => !v).length;
    unanswered = widget.quiz.questions.length - progress.userAnswers.length;
  }

  void _onAnswer(int index, String answer, bool isCorrect) {
    setState(() {
      progress.userAnswers[index] = answer;
      progress.correctness[index] = isCorrect;
      _updateCounters();
      _persistProgress();
    });
  }

  void _persistProgress() {
    print("PROGRESS PERSISTING: ${progress.toMap()}");
    prefs.setString(progressKey, progress.toJson());
  }

  void _showGenerateDialog() {
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
                  decoration: InputDecoration(
                    hintText:
                        "(Optional) Describe what new questions to generate...",
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isGenerating,
                ),
                SizedBox(height: 16),
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
                                  // Prepare quiz progress summary
                                  final incorrectIndices = progress
                                      .correctness
                                      .entries
                                      .where((e) => e.value == false)
                                      .map((e) => e.key)
                                      .toList();
                                  final incorrectQuestions = incorrectIndices
                                      .map((i) {
                                        final q = widget.quiz.questions[i];
                                        return {
                                          'index': i + 1,
                                          'question': q.question,
                                          if (q is MultipleChoiceQuizQuestion)
                                            'options': q.options
                                                .map((o) => o.text)
                                                .toList(),
                                          'correctAnswer': q.answer,
                                          'userAnswer': progress.userAnswers[i],
                                        };
                                      })
                                      .toList();
                                  final progressSummary = {
                                    'incorrectQuestions': incorrectQuestions,
                                    'totalQuestions':
                                        widget.quiz.questions.length,
                                    'correctCount': correct,
                                    'incorrectCount': incorrect,
                                    'unansweredCount': unanswered,
                                  };
                                  // Compose user message
                                  final userMessage = Content("user", [
                                    TextPart(
                                      "Here is my current quiz progress. Please focus on generating new questions that help me learn what I got wrong the most first.\n\nProgress (JSON):\n${jsonEncode(progressSummary)}${textController.text.trim().isNotEmpty ? "\n\nExtra instructions: ${textController.text.trim()}" : ""}",
                                    ),
                                  ]);
                                  final response = Inference.generateQuestions(
                                    userMessage,
                                  );
                                  progressStreamController =
                                      StreamController<String>.broadcast();
                                  response.progressText.listen((text) {
                                    if (progressStreamController != null &&
                                        !progressStreamController!.isClosed) {
                                      progressStreamController!.add(text);
                                    }
                                  });
                                  final newQuestions = await response.questions;
                                  setState(() {
                                    widget.quiz.addQuestions(newQuestions);
                                    _updateCounters();
                                  });
                                  if (progressStreamController != null &&
                                      !progressStreamController!.isClosed) {
                                    progressStreamController!.close();
                                  }
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  if (progressStreamController != null &&
                                      !progressStreamController!.isClosed) {
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
                              ? (progressText.isNotEmpty
                                    ? progressText
                                    : "Generating...")
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    // ...existing code...
    return Scaffold(
      appBar: AppBar(
        title: AppbarTitle(quiz: widget.quiz),
        actions: isMobile
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.greenAccent),
                      SizedBox(width: 4),
                      Text(
                        correct.toString(),
                        style: TextStyle(
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
                      Icon(Icons.close, color: Colors.redAccent),
                      SizedBox(width: 4),
                      Text(
                        incorrect.toString(),
                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: IconButton.filledTonal(
                    onPressed: _showGenerateDialog,
                    icon: Icon(Icons.edit),
                  ),
                ),
              ],
      ),
      body: Stack(
        children: [
          Center(
            child: ListView.builder(
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                final userAnswer = progress.userAnswers[index];
                Widget widgetView;
                if (question is MultipleChoiceQuizQuestion) {
                  widgetView = MultipleChoiceQuizQuestionView(
                    quizQuestion: question,
                    questionNumber: index,
                    userAnswer: userAnswer,
                    isCorrect: progress.correctness[index],
                    onAnswerSelected: (answer) {
                      final isCorrect = answer == question.answer;
                      _onAnswer(index, answer, isCorrect);
                    },
                  );
                } else {
                  widgetView = IdentificationQuizQuestionView(
                    quizQuestion: question,
                    questionNumber: index + 1,
                    userAnswer: userAnswer,
                    onAnswered: (answer, isCorrect) =>
                        _onAnswer(index, answer, isCorrect),
                  );
                }
                // Responsive horizontal padding
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.greenAccent),
                    SizedBox(width: 4),
                    Text(
                      correct.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.greenAccent),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.close, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text(
                      incorrect.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                    SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: _showGenerateDialog,
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
