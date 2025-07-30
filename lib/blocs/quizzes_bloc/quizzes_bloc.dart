import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/repositories/quiz_repository.dart';
import 'package:midnight_v1/classes/inference.dart';
import 'package:midnight_v1/classes/source.dart';

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
    try {
      final currentQuizzes = (state is QuizzesLoadSuccess)
          ? List<Quiz>.from((state as QuizzesLoadSuccess).quizzes)
          : await _quizRepository.loadQuizzes();

      // Add a placeholder quiz (disabled, with progress)
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

      final generateQuizResponse = Inference.generateQuiz(
        event.userMessage,
        event.sources ?? [],
      );
      // Show real progress
      emit(
        QuizGenerationInProgress(
          currentQuizzes,
          generateQuizResponse.progressText,
        ),
      );

      Quiz? newQuiz;
      try {
        newQuiz = await generateQuizResponse.quiz;
        // Save prompt and sources in quiz
        newQuiz = Quiz(
          id: newQuiz.id,
          title: newQuiz.title,
          questions: newQuiz.questions,
          generationPrompt: event.prompt ?? "",
          sources: event.sources ?? [],
        );
      } catch (e) {
        // Remove placeholder on error
        currentQuizzes.remove(placeholderQuiz);
        emit(QuizzesLoadFailure("Quiz generation failed: $e"));
        return;
      }
      // Replace placeholder with real quiz
      final idx = currentQuizzes.indexOf(placeholderQuiz);
      if (idx != -1) {
        currentQuizzes[idx] = newQuiz;
      } else {
        currentQuizzes.add(newQuiz);
      }
      await _quizRepository.saveQuizzes(currentQuizzes);
      emit(QuizzesLoadSuccess(currentQuizzes));
    } catch (e) {
      emit(QuizzesLoadFailure(e.toString()));
    }
  }

  Future<void> _onDeleteQuiz(
    DeleteQuiz event,
    Emitter<QuizzesState> emit,
  ) async {
    final quizzes = await _quizRepository.loadQuizzes();
    quizzes.removeWhere((q) => q.id == event.quiz.id);
    await _quizRepository.saveQuizzes(quizzes);
    add(LoadQuizzes());
  }

  Future<void> _onRenameQuiz(
    RenameQuiz event,
    Emitter<QuizzesState> emit,
  ) async {
    final quizzes = await _quizRepository.loadQuizzes();
    final index = quizzes.indexWhere((q) => q.id == event.quiz.id);
    if (index != -1) {
      quizzes[index] = Quiz(
        id: event.quiz.id,
        title: event.newTitle,
        questions: event.quiz.questions,
      );
      await _quizRepository.saveQuizzes(quizzes);
      add(LoadQuizzes());
    }
  }

  Future<void> _onClearAllQuizzes(
    ClearAllQuizzes event,
    Emitter<QuizzesState> emit,
  ) async {
    await _quizRepository.saveQuizzes([]);
    add(LoadQuizzes());
  }
}
