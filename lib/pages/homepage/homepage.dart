import 'package:midnight_v1/classes/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/pages/homepage/homepage_drawer.dart';
import 'package:midnight_v1/pages/homepage/main_title.dart';
import 'package:midnight_v1/pages/homepage/quiz_generation_container.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final isMobile = sizes.width < 600;

    return Scaffold(
      appBar: AppBar(),
      drawer: const HomepageDrawer(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8.0 : 64.0,
            vertical: isMobile ? 8.0 : 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainTitle(size: isMobile ? 0.75 : 1),
              SizedBox(height: isMobile ? 16 : 32),
              const QuizGenerationContainer(),
              SizedBox(
                width: sizes.width * (isMobile ? 0.95 : 0.6),
                child: BlocBuilder<QuizzesBloc, QuizzesState>(
                  builder: (context, state) {
                    final List<Quiz> quizzes = [];
                    Stream<String>? progressStream;
                    if (state is QuizzesLoadSuccess) {
                      quizzes.addAll(state.quizzes);
                    } else if (state is QuizGenerationInProgress) {
                      quizzes.addAll(state.quizzes);
                      progressStream = state.progressText;
                    } else if (state is QuizzesLoadInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is QuizzesLoadFailure) {
                      return Center(child: Text(state.error));
                    } else {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        SizedBox(height: isMobile ? 8 : 16),
                        ...quizzes
                            .sublist(
                              (quizzes.length < 3) ? 0 : quizzes.length - 3,
                              quizzes.length,
                            )
                            .map((quiz) {
                              final isGenerating = quiz.questions.isEmpty;
                              return Column(
                                children: [
                                  TextButton(
                                    onPressed: isGenerating
                                        ? null
                                        : () => Navigator.of(
                                            context,
                                          ).pushNamed("/quiz", arguments: quiz),
                                    child: Text(quiz.title),
                                  ),
                                  if (isGenerating && progressStream != null)
                                    StreamBuilder<String>(
                                      stream: progressStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.isNotEmpty) {
                                          return Text(
                                            snapshot.data!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                ],
                              );
                            })
                            .toList()
                            .reversed,
                        SizedBox(height: isMobile ? 8 : 16),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
