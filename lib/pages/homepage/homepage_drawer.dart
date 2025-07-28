import 'package:flutter/material.dart';
import 'package:midnight_v1/classes/app_data.dart';
import 'package:provider/provider.dart';
import 'package:midnight_v1/classes/quiz.dart';

class HomepageDrawer extends StatelessWidget {
  const HomepageDrawer({super.key});

  static void showQuizMenuOverlay(
    BuildContext context,
    AppData appData,
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
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                    onTap: () async {
                      entry.remove();
                      final newTitle = await HomepageDrawer.showRenameDialog(
                        context,
                        quiz.title,
                      );
                      if (newTitle != null && newTitle.isNotEmpty) {
                        await appData.renameQuiz(quiz, newTitle);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Regenerate'),
                    onTap: () async {
                      entry.remove();
                      await appData.regenerateQuiz(quiz);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () async {
                      entry.remove();
                      await appData.deleteQuiz(quiz);
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
        title: Text('Rename Quiz'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'New quiz title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

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
          SizedBox(height: 16),
          ListTile(
            title: Text("Account"),
            leading: Icon(Icons.person),
            onTap: () {},
          ),
          ListTile(
            title: Text("Settings"),
            leading: Icon(Icons.settings),
            onTap: () => Navigator.of(context).pushNamed("/settings"),
          ),
          Divider(),
          SingleChildScrollView(
            child: Column(
              children: appData.quizzes
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
                              appData,
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
                              appData,
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
          ),
        ],
      ),
    );
  }
}
