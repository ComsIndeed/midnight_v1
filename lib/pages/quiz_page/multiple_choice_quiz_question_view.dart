import 'package:flutter/material.dart';
import 'package:midnight_v1/models/quiz.dart';

class MultipleChoiceQuizQuestionView extends StatefulWidget {
  const MultipleChoiceQuizQuestionView({
    super.key,
    required this.quizQuestion,
    required this.questionNumber,
    required this.userAnswer,
    required this.isCorrect,
    required this.onAnswerSelected,
  });

  final MultipleChoiceQuizQuestion quizQuestion;
  final int questionNumber;
  final String? userAnswer;
  final bool? isCorrect;
  final ValueChanged<String> onAnswerSelected;

  @override
  State<MultipleChoiceQuizQuestionView> createState() =>
      _MultipleChoiceQuizQuestionViewState();
}

class _MultipleChoiceQuizQuestionViewState
    extends State<MultipleChoiceQuizQuestionView> {
  late String selectedAnswer;

  @override
  void initState() {
    super.initState();
    selectedAnswer = widget.userAnswer ?? '';
  }

  void _select(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
    widget.onAnswerSelected(answer);
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
        ...widget.quizQuestion.options.asMap().entries.map((entry) {
          final index = entry.key;
          final choice = entry.value;
          final letter = String.fromCharCode(65 + index); // 65 = 'A'
          final isSelected = selectedAnswer == choice.text;
          final isCorrectAnswer = choice.text == widget.quizQuestion.answer;
          final shouldHighlightCorrect = isCorrect == false && isCorrectAnswer;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Container(
              decoration: shouldHighlightCorrect
                  ? BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 1),
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.yellow.withAlpha(20),
                    )
                  : null,
              child: TextButton(
                onPressed: widget.userAnswer == null
                    ? () => _select(choice.text)
                    : null,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: isSelected
                      ? (isCorrect == null
                            ? Colors.blue.shade900.withAlpha(100)
                            : (isCorrect
                                  ? Colors.green.shade900.withAlpha(100)
                                  : Colors.red.shade900.withAlpha(100)))
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        '$letter.',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Wrap(children: [Text(choice.text)])),
                      if (isSelected && isCorrect != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        SizedBox(height: 64),
      ],
    );
  }
}
