import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/models/quiz.dart';
import 'package:midnight_v1/pages/homepage/homepage_drawer.dart';
import 'package:midnight_v1/pages/homepage/main_title.dart';
import 'package:midnight_v1/pages/homepage/quiz_generation_container.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final isMobile = sizes.width < 600;

    return Scaffold(
      appBar: AppBar(),
      drawer: HomepageDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MainTitle(),
            Text("Generate study materials and more"),
            SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 140,
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        surfaceTintColor: Colors.yellow,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.note_add_outlined),
                                SizedBox(width: 4),
                                Expanded(child: Text("Create Note")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      width: 140,
                      child: Card(
                        surfaceTintColor: Colors.green,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.question_answer_outlined),
                                SizedBox(width: 4),
                                Expanded(child: Text("Generate Quiz")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      width: 140,
                      child: Card(
                        surfaceTintColor: Colors.red,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.copy_outlined),
                                SizedBox(width: 4),
                                Expanded(child: Text("Flash Cards")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      width: 140,
                      child: Card(
                        surfaceTintColor: Colors.blue,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.document_scanner_outlined),
                                SizedBox(width: 4),
                                Expanded(child: Text("Generate Materials")),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4),
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
    );
  }
}
