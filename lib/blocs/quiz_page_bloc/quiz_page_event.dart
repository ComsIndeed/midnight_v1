part of 'quiz_page_bloc.dart';

abstract class QuizPageEvent extends Equatable {
  const QuizPageEvent();

  @override
  List<Object> get props => [];
}

class LoadQuizProgress extends QuizPageEvent {
  final Quiz quiz;
  const LoadQuizProgress(this.quiz);

  @override
  List<Object> get props => [quiz];
}

class AnswerSubmitted extends QuizPageEvent {
  final int questionIndex;
  final String answer;
  const AnswerSubmitted(this.questionIndex, this.answer);

  @override
  List<Object> get props => [questionIndex, answer];
}

class GenerateNewQuestions extends QuizPageEvent {
  final String? description;
  const GenerateNewQuestions({this.description});

  @override
  List<Object> get props => [description ?? ''];
}

