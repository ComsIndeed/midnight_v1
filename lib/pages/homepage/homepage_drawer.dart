import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/models/quiz.dart';
import 'package:midnight_v1/utils/dialog_helpers.dart';

class HomepageDrawer extends StatelessWidget {
  const HomepageDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor.bar(
                barHintText: "Search Quizzes",
                suggestionsBuilder: (context, controller) {
                  final quizzesState = context.read<QuizzesBloc>().state;
                  List<Quiz> allQuizzes = [];
                  if (quizzesState is QuizzesLoadSuccess) {
                    allQuizzes.addAll(quizzesState.quizzes);
                  } else if (quizzesState is QuizGenerationInProgress) {
                    allQuizzes.addAll(quizzesState.quizzes);
                  }
                  final filteredQuizzes = allQuizzes.where((quiz) {
                    return quiz.title.toLowerCase().contains(
                      controller.text.toLowerCase(),
                    );
                  }).toList();
                  if (controller.text.isEmpty) {
                    return [
                      const Center(
                        child: Text('Start typing to search for quizzes.'),
                      ),
                    ];
                  }
                  if (filteredQuizzes.isEmpty) {
                    return [const Center(child: Text('No quizzes found.'))];
                  }
                  return filteredQuizzes.map((quiz) {
                    return ListTile(
                      title: Text(quiz.title),
                      onTap: () {
                        controller.closeView(quiz.title);
                        Navigator.of(
                          context,
                        ).pushNamed("/quiz", arguments: quiz);
                      },
                    );
                  }).toList();
                },
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Account & Settings"),
              leading: const Icon(Icons.account_circle),
              onTap: () => Navigator.of(context).pushNamed("/settings"),
            ),
            ListTile(
              title: const Text("Study"),
              leading: const Icon(Icons.lightbulb),
              onTap: () => Navigator.of(context).pushNamed("/study"),
            ),
            ExpansionTile(
              title: const Text("Chats"),
              leading: const Icon(Icons.chat),
              children: [
                ListTile(
                  onTap: () => Navigator.of(context).pushNamed("/chats"),
                  title: Text("TEST"),
                ),
              ],
            ),
            const Divider(),
            BlocBuilder<QuizzesBloc, QuizzesState>(
              builder: (context, state) {
                final List<Quiz> quizzes = [];
                Stream<String>? progressStream;
                if (state is QuizzesLoadSuccess) {
                  quizzes.addAll(state.quizzes);
                } else if (state is QuizGenerationInProgress) {
                  quizzes.addAll(state.quizzes);
                  progressStream = state.progressText;
                }
                if (quizzes.isEmpty) return const SizedBox.shrink();
                return SingleChildScrollView(
                  child: Column(
                    children: quizzes
                        .map(
                          (quiz) => Builder(
                            builder: (itemContext) {
                              final isGenerating = quiz.questions.isEmpty;
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: isGenerating
                                        ? null
                                        : () => Navigator.of(
                                            context,
                                          ).pushNamed("/quiz", arguments: quiz),
                                    onSecondaryTap: isGenerating
                                        ? null
                                        : () {
                                            final box =
                                                itemContext.findRenderObject()
                                                    as RenderBox?;
                                            final position =
                                                box?.localToGlobal(
                                                  Offset.zero,
                                                ) ??
                                                Offset.zero;
                                            showQuizMenuOverlay(
                                              context,
                                              quiz,
                                              position +
                                                  Offset(
                                                    box?.size.width ?? 0,
                                                    0,
                                                  ),
                                            );
                                          },
                                    onLongPress: isGenerating
                                        ? null
                                        : () {
                                            final box =
                                                itemContext.findRenderObject()
                                                    as RenderBox?;
                                            final position =
                                                box?.localToGlobal(
                                                  Offset.zero,
                                                ) ??
                                                Offset.zero;
                                            showQuizMenuOverlay(
                                              context,
                                              quiz,
                                              position +
                                                  Offset(
                                                    box?.size.width ?? 0,
                                                    0,
                                                  ),
                                            );
                                          },
                                    child: ListTile(
                                      title: Text(quiz.title),
                                      enabled: !isGenerating,
                                    ),
                                  ),
                                  if (isGenerating && progressStream != null)
                                    StreamBuilder<String>(
                                      stream: progressStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.isNotEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: Text(
                                              snapshot.data!,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                        )
                        .toList()
                        .reversed
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
