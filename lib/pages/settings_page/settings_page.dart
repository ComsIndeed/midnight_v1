import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/pages/settings_page/enable_identification_quiz_preview.dart';
import 'package:midnight_v1/pages/settings_page/gemini_api_key_field.dart';
import 'package:midnight_v1/services/app_prefs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const GeminiApiKeyField(),
            StatefulBuilder(
              builder: (context, setState) {
                return SwitchListTile(
                  title: const Text("Enable Embeddings (for quiz generation)"),
                  value: AppPrefs.instance.embeddingEnabled,
                  onChanged: (val) async {
                    AppPrefs.instance.embeddingEnabled = val;
                    setState(() {});
                  },
                  subtitle: const Text(
                    "Default: Disabled. Embeddings improve semantic search but slow down quiz generation.",
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Clear quizzes"),
              leading: const Icon(Icons.delete),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text(
                      'Are you sure you want to clear all quizzes? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  if (!context.mounted) return;
                  context.read<QuizzesBloc>().add(ClearAllQuizzes());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All quizzes cleared.')),
                  );
                }
              },
            ),
            EnableIdentificationQuizPreview(),
          ],
        ),
      ),
    );
  }
}
