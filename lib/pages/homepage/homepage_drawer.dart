import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/classes/quiz.dart';

class HomepageDrawer extends StatelessWidget {
  const HomepageDrawer({super.key});

  static void showQuizMenuOverlay(
    BuildContext context,
    Quiz quiz,
    Offset position,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            color: Colors.transparent,
            child: Card(
              elevation: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Rename'),
                    onTap: () async {
                      entry.remove();
                      final newTitle = await HomepageDrawer.showRenameDialog(
                        context,
                        quiz.title,
                      );
                      if (newTitle != null && newTitle.isNotEmpty) {
                        context.read<QuizzesBloc>().add(RenameQuiz(quiz, newTitle));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () async {
                      entry.remove();
                      context.read<QuizzesBloc>().add(DeleteQuiz(quiz));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
  }

  static Future<String?> showRenameDialog(
    BuildContext context,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Quiz'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New quiz title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor.bar(
              barHintText: "Search Quizzes",
              suggestionsBuilder: (context, controller) {
                return [];
              },
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text("Account"),
            leading: const Icon(Icons.person),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Settings"),
            leading: const Icon(Icons.settings),
            onTap: () => Navigator.of(context).pushNamed("/settings"),
          ),
          const Divider(),
          BlocBuilder<QuizzesBloc, QuizzesState>(
            builder: (context, state) {
              if (state is QuizzesLoadSuccess) {
                return SingleChildScrollView(
                  child: Column(
                    children: state.quizzes
                        .map(
                          (quiz) => Builder(
                            builder: (itemContext) {
                              return InkWell(
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed("/quiz", arguments: quiz),
                                onSecondaryTap: () {
                                  // Desktop right click
                                  final box =
                                      itemContext.findRenderObject() as RenderBox?;
                                  final position =
                                      box?.localToGlobal(Offset.zero) ?? Offset.zero;
                                  HomepageDrawer.showQuizMenuOverlay(
                                    context,
                                    quiz,
                                    position + Offset(box?.size.width ?? 0, 0),
                                  );
                                },
                                onLongPress: () {
                                  // Mobile long press
                                  final box =
                                      itemContext.findRenderObject() as RenderBox?;
                                  final position =
                                      box?.localToGlobal(Offset.zero) ?? Offset.zero;
                                  HomepageDrawer.showQuizMenuOverlay(
                                    context,
                                    quiz,
                                    position + Offset(box?.size.width ?? 0, 0),
                                  );
                                },
                                child: ListTile(title: Text(quiz.title)),
                              );
                            },
                          ),
                        )
                        .toList()
                        .reversed
                        .toList(),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
