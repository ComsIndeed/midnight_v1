part of 'quizzes_bloc.dart';

abstract class QuizzesState extends Equatable {
  const QuizzesState();

  @override
  List<Object?> get props => [];
}

class QuizzesInitial extends QuizzesState {}

class QuizzesLoadInProgress extends QuizzesState {}

class QuizzesLoadSuccess extends QuizzesState {
  final List<Quiz> quizzes;
  const QuizzesLoadSuccess(this.quizzes);

  @override
  List<Object> get props => [quizzes];
}

class QuizGenerationInProgress extends QuizzesState {
  final List<Quiz> quizzes;
  final Stream<String> progressText;

  const QuizGenerationInProgress(this.quizzes, this.progressText);

  @override
  List<Object?> get props => [quizzes, progressText];
}

class QuizzesLoadFailure extends QuizzesState {
  final String error;
  const QuizzesLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
