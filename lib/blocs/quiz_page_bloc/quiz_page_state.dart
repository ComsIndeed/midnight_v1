part of 'quiz_page_bloc.dart';

abstract class QuizPageState extends Equatable {
  const QuizPageState();

  @override
  List<Object> get props => [];
}

class QuizPageInitial extends QuizPageState {}

class QuizPageLoadInProgress extends QuizPageState {}

class QuizPageLoadSuccess extends QuizPageState {
  final Quiz quiz;
  final QuizProgress progress;
  final int correctCount;
  final int incorrectCount;
  final int unansweredCount;

  const QuizPageLoadSuccess({
    required this.quiz,
    required this.progress,
    required this.correctCount,
    required this.incorrectCount,
    required this.unansweredCount,
  });

  @override
  List<Object> get props => [
    quiz,
    progress,
    correctCount,
    incorrectCount,
    unansweredCount,
  ];
}

class QuizPageGeneratingQuestions extends QuizPageState {
  final Quiz quiz;
  final QuizProgress progress;
  final int correctCount;
  final int incorrectCount;
  final int unansweredCount;

  const QuizPageGeneratingQuestions({
    required this.quiz,
    required this.progress,
    required this.correctCount,
    required this.incorrectCount,
    required this.unansweredCount,
  });

  @override
  List<Object> get props => [
        quiz,
        progress,
        correctCount,
        incorrectCount,
        unansweredCount,
      ];
}

class QuizPageLoadFailure extends QuizPageState {
  final String error;

  const QuizPageLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

