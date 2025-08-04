import 'package:flutter/material.dart';
import 'package:midnight_v1/services/app_prefs.dart';

class EnableIdentificationQuizPreview extends StatefulWidget {
  const EnableIdentificationQuizPreview({super.key});

  @override
  State<EnableIdentificationQuizPreview> createState() =>
      _EnableIdentificationQuizPreviewState();
}

class _EnableIdentificationQuizPreviewState
    extends State<EnableIdentificationQuizPreview> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text("Use identification items for quizzes"),
      subtitle: Text(
        "This is an experimental feature. This was made in just 20 minutes, there are bugs.",
      ),
      value: AppPrefs.instance.useIdentificationQuestions,
      onChanged: (val) {
        AppPrefs.instance.useIdentificationQuestions = val;
        setState(() {});
      },
    );
  }
}
