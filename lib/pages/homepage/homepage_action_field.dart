import 'package:flutter/material.dart';

class HomepageActionField extends StatefulWidget {
  const HomepageActionField({super.key});

  @override
  State<HomepageActionField> createState() => _HomepageActionFieldState();
}

class _HomepageActionFieldState extends State<HomepageActionField> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Durations.medium1,
      curve: Curves.easeInOutCubicEmphasized,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.text.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.search),
              label: Text("Search: ${controller.text.trim()}"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.message),
              label: Text("Send: ${controller.text.trim()}"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.lightbulb),
              label: Text("Generate: ${controller.text.trim()}"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.note_add),
              label: Text("Note: ${controller.text.trim()}"),
            ),
          ],
          SearchBar(
            controller: controller,
            onChanged: (_) => setState(() {}),
            hintText: "What can we do for you?",
            leading: IconButton.filledTonal(
              onPressed: () {},
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
