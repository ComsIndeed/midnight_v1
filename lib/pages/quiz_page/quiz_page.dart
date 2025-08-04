import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quiz_page_bloc/quiz_page_bloc.dart';
import 'package:midnight_v1/services/app_prefs.dart';
import 'package:midnight_v1/models/quiz.dart';
import 'package:midnight_v1/pages/quiz_page/appbar_title.dart';
import 'package:midnight_v1/pages/quiz_page/identification_quiz_question_view.dart';
import 'package:midnight_v1/pages/quiz_page/multiple_choice_quiz_question_view.dart';
import 'package:responsive_framework/responsive_framework.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quiz});

  final Quiz quiz;

  void _showGenerateDialog(BuildContext context) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<QuizPageBloc>().add(
                        GenerateNewQuestions(
                          description: textController.text,
                        ),
                      );
                  Navigator.of(context).pop();
                },
                child: const Text("Generate"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return BlocBuilder<QuizPageBloc, QuizPageState>(
      builder: (context, state) {
        if (state is QuizPageLoadInProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: IconButton.filledTonal(
                          onPressed: () => _showGenerateDialog(context),
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
                      if (question is MultipleChoiceQuizQuestion &&
                          !AppPrefs.instance.useIdentificationQuestions) {
                        widgetView = MultipleChoiceQuizQuestionView(
                          quizQuestion: question,
                          questionNumber: index,
                          userAnswer: userAnswer,
                          isCorrect: state.progress.correctness[index],
                          onAnswerSelected: (answer) {
                            context.read<QuizPageBloc>().add(
                              AnswerSubmitted(index, answer),
                            );
                          },
                        );
                      } else {
                        widgetView = IdentificationQuizQuestionView(
                          quizQuestion: question,
                          questionNumber: index,
                          userAnswer: userAnswer,
                          isCorrect: state.progress.correctness[index],
                          onAnswerSubmitted: (answer) {
                            context.read<QuizPageBloc>().add(
                              AnswerSubmitted(index, answer),
                            );
                          },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(width: 16),
                          const Icon(Icons.close, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            state.incorrectCount.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton.filled(
                            onPressed: () => _showGenerateDialog(context),
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
        return const Scaffold(
          body: Center(child: Text("Something went wrong.")),
        );
      },
    );
  }
}