import 'package:flutter/material.dart';
import 'package:midnight_v1/models/quiz.dart';

class IdentificationQuizQuestionView extends StatefulWidget {
  const IdentificationQuizQuestionView({
    super.key,
    required this.quizQuestion,
    required this.questionNumber,
    required this.userAnswer,
    required this.isCorrect,
    required this.onAnswerSubmitted,
  });

  final QuizQuestion quizQuestion;
  final int questionNumber;
  final String? userAnswer;
  final bool? isCorrect;
  final ValueChanged<String> onAnswerSubmitted;

  @override
  State<IdentificationQuizQuestionView> createState() =>
      _IdentificationQuizQuestionViewState();
}

class _IdentificationQuizQuestionViewState
    extends State<IdentificationQuizQuestionView> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.userAnswer ?? "");
  }

  @override
  void didUpdateWidget(covariant IdentificationQuizQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userAnswer != oldWidget.userAnswer) {
      controller.text = widget.userAnswer ?? "";
    }
  }

  void _submit(String value) {
    widget.onAnswerSubmitted(value);
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.isCorrect;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${widget.questionNumber + 1}',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w100,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          widget.quizQuestion.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Type your answer here...",
              suffixIcon: isCorrect == null
                  ? null
                  : Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
            ),
            onSubmitted: widget.userAnswer == null ? _submit : null,
            enabled: widget.userAnswer == null,
          ),
        ),
        if (isCorrect != null)
          Text("Correct answer: ${widget.quizQuestion.answer}"),
        const SizedBox(height: 64),
      ],
    );
  }
}
