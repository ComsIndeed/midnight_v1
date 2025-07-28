import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:midnight_v1/classes/app_data.dart';
import 'package:midnight_v1/pages/settings_page/gemini_api_key_field.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GeminiApiKeyField(),
            ListTile(
              title: Text("Clear quizzes"),
              leading: Icon(Icons.delete),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm'),
                    content: Text(
                      'Are you sure you want to clear all quizzes? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  // Get AppData from Provider and clear quizzes
                  final appData = Provider.of<AppData>(context, listen: false);
                  await appData.clearAllQuizzes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All quizzes cleared.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
