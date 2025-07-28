import 'package:flutter/material.dart';
import 'package:midnight_v1/classes/quiz.dart';

class IdentificationQuizQuestionView extends StatefulWidget {
  const IdentificationQuizQuestionView({
    super.key,
    required this.quizQuestion,
    required this.questionNumber,
    this.userAnswer,
    required this.onAnswered,
  });

  final QuizQuestion quizQuestion;
  final int questionNumber;
  final String? userAnswer;
  final void Function(String answer, bool isCorrect) onAnswered;

  @override
  State<IdentificationQuizQuestionView> createState() =>
      _IdentificationQuizQuestionViewState();
}

class _IdentificationQuizQuestionViewState
    extends State<IdentificationQuizQuestionView> {
  late TextEditingController controller;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.userAnswer ?? "");
    if (widget.userAnswer != null) {
      isCorrect =
          widget.userAnswer!.trim().toLowerCase() ==
          widget.quizQuestion.answer.trim().toLowerCase();
    }
  }

  @override
  void didUpdateWidget(covariant IdentificationQuizQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userAnswer != oldWidget.userAnswer) {
      controller.text = widget.userAnswer ?? "";
      if (widget.userAnswer != null) {
        isCorrect =
            widget.userAnswer!.trim().toLowerCase() ==
            widget.quizQuestion.answer.trim().toLowerCase();
      }
    }
  }

  void _submit(String value) {
    final correct =
        value.trim().toLowerCase() ==
        widget.quizQuestion.answer.trim().toLowerCase();
    setState(() {
      isCorrect = correct;
    });
    widget.onAnswered(value, correct);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    return Column(
      children: [
        Text('${widget.questionNumber}. ${widget.quizQuestion.question}'),
        SizedBox(
          height: 64,
          width: sizes.width * 0.8,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Answer",
              suffixIcon: isCorrect == null
                  ? null
                  : Icon(
                      isCorrect! ? Icons.check : Icons.close,
                      color: isCorrect! ? Colors.green : Colors.red,
                    ),
            ),
            onSubmitted: _submit,
            enabled: widget.userAnswer == null,
          ),
        ),
      ],
    );
  }
}
