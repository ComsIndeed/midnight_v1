part of 'quizzes_bloc.dart';

abstract class QuizzesEvent extends Equatable {
  const QuizzesEvent();

  @override
  List<Object> get props => [];
}

class LoadQuizzes extends QuizzesEvent {}

class GenerateQuiz extends QuizzesEvent {
  final Content userMessage;
  const GenerateQuiz(this.userMessage);

  @override
  List<Object> get props => [userMessage];
}

class DeleteQuiz extends QuizzesEvent {
  final Quiz quiz;
  const DeleteQuiz(this.quiz);

  @override
  List<Object> get props => [quiz];
}

class ClearAllQuizzes extends QuizzesEvent {}

class RenameQuiz extends QuizzesEvent {
  final Quiz quiz;
  final String newTitle;

  const RenameQuiz(this.quiz, this.newTitle);

  @override
  List<Object> get props => [quiz, newTitle];
}
