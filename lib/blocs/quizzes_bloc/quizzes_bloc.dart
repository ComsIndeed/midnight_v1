import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/models/quiz.dart';
import 'package:midnight_v1/repositories/quiz_repository.dart';
import 'package:midnight_v1/services/inference.dart';
import 'package:midnight_v1/models/source.dart';

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

  Future<void> _onLoadQuizzes(
    LoadQuizzes event,
    Emitter<QuizzesState> emit,
  ) async {
    emit(QuizzesLoadInProgress());
    try {
      final quizzes = await _quizRepository.loadQuizzes();
      emit(QuizzesLoadSuccess(quizzes));
    } catch (e) {
      emit(QuizzesLoadFailure(e.toString()));
    }
  }

  Future<void> _onGenerateQuiz(
    GenerateQuiz event,
    Emitter<QuizzesState> emit,
  ) async {
    final currentState = state;
    List<Quiz> currentQuizzes = [];
    if (currentState is QuizzesLoadSuccess) {
      currentQuizzes = List<Quiz>.from(currentState.quizzes);
    } else if (currentState is QuizGenerationInProgress) {
      currentQuizzes = List<Quiz>.from(currentState.quizzes);
    }

    final placeholderQuiz = Quiz(
      id: Quiz.generateUuid(),
      title: "Generating...",
      questions: [],
      generationPrompt: event.prompt ?? "",
      sources: event.sources ?? [],
    );
    currentQuizzes.add(placeholderQuiz);
    emit(
      QuizGenerationInProgress(currentQuizzes, Stream.value("Starting...")),
    );

    try {
      final generateQuizResponse = Inference.generateQuiz(
        event.userMessage,
        event.sources ?? [],
      );

      emit(
        QuizGenerationInProgress(
          currentQuizzes,
          generateQuizResponse.progressText,
        ),
      );

      final newQuiz = await generateQuizResponse.quiz;
      final finalQuiz = Quiz(
        id: newQuiz.id,
        title: newQuiz.title,
        questions: newQuiz.questions,
        generationPrompt: event.prompt ?? "",
        sources: event.sources ?? [],
      );

      final idx = currentQuizzes.indexOf(placeholderQuiz);
      if (idx != -1) {
        currentQuizzes[idx] = finalQuiz;
      } else {
        currentQuizzes.add(finalQuiz);
      }

      await _quizRepository.saveQuizzes(currentQuizzes);
      emit(QuizzesLoadSuccess(currentQuizzes));
    } catch (e) {
      currentQuizzes.remove(placeholderQuiz);
      emit(QuizzesLoadFailure("Quiz generation failed: $e"));
    }
  }

  Future<void> _onDeleteQuiz(
    DeleteQuiz event,
    Emitter<QuizzesState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuizzesLoadSuccess) {
      final updatedQuizzes = List<Quiz>.from(currentState.quizzes)
        ..removeWhere((q) => q.id == event.quiz.id);
      emit(QuizzesLoadSuccess(updatedQuizzes));
      await _quizRepository.saveQuizzes(updatedQuizzes);
    }
  }

  Future<void> _onRenameQuiz(
    RenameQuiz event,
    Emitter<QuizzesState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuizzesLoadSuccess) {
      final quizzes = List<Quiz>.from(currentState.quizzes);
      final index = quizzes.indexWhere((q) => q.id == event.quiz.id);
      if (index != -1) {
        quizzes[index] = Quiz(
          id: event.quiz.id,
          title: event.newTitle,
          questions: event.quiz.questions,
        );
        emit(QuizzesLoadSuccess(quizzes));
        await _quizRepository.saveQuizzes(quizzes);
      }
    }
  }

  Future<void> _onClearAllQuizzes(
    ClearAllQuizzes event,
    Emitter<QuizzesState> emit,
  ) async {
    emit(const QuizzesLoadSuccess([]));
    await _quizRepository.saveQuizzes([]);
  }
}
