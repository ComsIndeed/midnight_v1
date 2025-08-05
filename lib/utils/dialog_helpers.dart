import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/models/quiz.dart';

void showQuizMenuOverlay(
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
                    final newTitle = await showRenameDialog(
                      context,
                      quiz.title,
                    );
                    if (newTitle != null && newTitle.isNotEmpty) {
                      if (!context.mounted) return;
                      context.read<QuizzesBloc>().add(
                            RenameQuiz(quiz, newTitle),
                          );
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

Future<String?> showRenameDialog(
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
