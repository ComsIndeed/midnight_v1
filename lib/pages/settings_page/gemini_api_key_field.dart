import 'package:flutter/material.dart';
import 'package:midnight_v1/services/app_prefs.dart';

class GeminiApiKeyField extends StatefulWidget {
  const GeminiApiKeyField({super.key});

  @override
  State<GeminiApiKeyField> createState() => _GeminiApiKeyFieldState();
}

class _GeminiApiKeyFieldState extends State<GeminiApiKeyField> {
  final controller = TextEditingController();

  void setApiKey(BuildContext context) {
    AppPrefs.instance.apiKey = controller.text;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('API Key set')));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        obscureText: true,
        controller: controller,
        decoration: InputDecoration(
          labelText: 'API Key',
          border: OutlineInputBorder(),
          suffix: IconButton(
            onPressed: () => AppPrefs.instance.apiKey = controller.text,
            icon: Icon(Icons.check),
          ),
        ),
      ),
    );
  }
}
