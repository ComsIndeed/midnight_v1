import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/repositories/quiz_repository.dart';
import 'package:midnight_v1/classes/inference.dart';

part 'quizzes_event.dart';
part 'quizzes_state.dart';

class QuizzesBloc extends Bloc<QuizzesEvent, QuizzesState> {
  final QuizRepository _quizRepository;

  QuizzesBloc(this._quizRepository) : super(QuizzesInitial()) {
    on<LoadQuizzes>(_onLoadQuizzes);
    on<GenerateQuiz>(_onGenerateQuiz);
    on<DeleteQuiz>(_onDeleteQuiz);
    on<RenameQuiz>(_onRenameQuiz);
    on<ClearAllQuizzes>(_onClearAllQuizzes);
  }

  Future<void> _onLoadQuizzes(LoadQuizzes event, Emitter<QuizzesState> emit) async {
    emit(QuizzesLoadInProgress());
    try {
      final quizzes = await _quizRepository.loadQuizzes();
      emit(QuizzesLoadSuccess(quizzes));
    } catch (e) {
      emit(QuizzesLoadFailure(e.toString()));
    }
  }

  Future<void> _onGenerateQuiz(GenerateQuiz event, Emitter<QuizzesState> emit) async {
    try {
      final currentQuizzes = (state is QuizzesLoadSuccess) ? (state as QuizzesLoadSuccess).quizzes : await _quizRepository.loadQuizzes();
      final generateQuizResponse = Inference.generateQuiz(event.userMessage, []);

      emit(QuizGenerationInProgress(currentQuizzes, generateQuizResponse.progressText));

      final newQuiz = await generateQuizResponse.quiz;
      currentQuizzes.add(newQuiz);
      await _quizRepository.saveQuizzes(currentQuizzes);
      emit(QuizzesLoadSuccess(currentQuizzes));
    } catch (e) {
      emit(QuizzesLoadFailure(e.toString()));
    }
  }

  Future<void> _onDeleteQuiz(DeleteQuiz event, Emitter<QuizzesState> emit) async {
    final quizzes = await _quizRepository.loadQuizzes();
    quizzes.removeWhere((q) => q.title == event.quiz.title);
    await _quizRepository.saveQuizzes(quizzes);
    add(LoadQuizzes());
  }

  Future<void> _onRenameQuiz(RenameQuiz event, Emitter<QuizzesState> emit) async {
    final quizzes = await _quizRepository.loadQuizzes();
    final index = quizzes.indexWhere((q) => q.title == event.quiz.title);
    if (index != -1) {
      quizzes[index] = Quiz(title: event.newTitle, questions: event.quiz.questions);
      await _quizRepository.saveQuizzes(quizzes);
      add(LoadQuizzes());
    }
  }

  Future<void> _onClearAllQuizzes(
      ClearAllQuizzes event, Emitter<QuizzesState> emit) async {
    await _quizRepository.saveQuizzes([]);
    add(LoadQuizzes());
  }
}
