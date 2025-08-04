import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:midnight_v1/models/quiz_progress.dart';
import 'package:midnight_v1/models/quiz.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/services/inference.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'quiz_page_event.dart';
part 'quiz_page_state.dart';

// Top-level function for decoding in a background isolate
QuizProgress _decodeQuizProgress(String json) {
  return QuizProgress.fromMap(jsonDecode(json));
}

// Top-level function for encoding in a background isolate
String _encodeQuizProgress(QuizProgress progress) {
  return jsonEncode(progress.toMap());
}

class QuizPageBloc extends Bloc<QuizPageEvent, QuizPageState> {
  final SharedPreferences prefs;

  QuizPageBloc(this.prefs) : super(QuizPageInitial()) {
    on<LoadQuizProgress>(_onLoadQuizProgress);
    on<AnswerSubmitted>(_onAnswerSubmitted);
    on<GenerateNewQuestions>(_onGenerateNewQuestions);
    on<GenerateNewQuestions>(_onGenerateNewQuestions);
  }

  Future<void> _onLoadQuizProgress(
    LoadQuizProgress event,
    Emitter<QuizPageState> emit,
  ) async {
    emit(QuizPageLoadInProgress());
    try {
      final progress = await _loadProgress(event.quiz.id);
      final counters = _updateCounters(event.quiz, progress);
      emit(
        QuizPageLoadSuccess(
          quiz: event.quiz,
          progress: progress,
          correctCount: counters['correct']!,
          incorrectCount: counters['incorrect']!,
          unansweredCount: counters['unanswered']!,
        ),
      );
    } catch (e) {
      emit(QuizPageLoadFailure(e.toString()));
    }
  }

  Future<void> _onAnswerSubmitted(
    AnswerSubmitted event,
    Emitter<QuizPageState> emit,
  ) async {
    if (state is QuizPageLoadSuccess) {
      final currentState = state as QuizPageLoadSuccess;
      final isCorrect =
          currentState.quiz.questions[event.questionIndex].answer ==
          event.answer;
      final newProgress = QuizProgress(
        userAnswers: Map.from(currentState.progress.userAnswers)
          ..[event.questionIndex] = event.answer,
        correctness: Map.from(currentState.progress.correctness)
          ..[event.questionIndex] = isCorrect,
      );

      await _persistProgress(currentState.quiz.id, newProgress);
      final counters = _updateCounters(currentState.quiz, newProgress);

      emit(
        QuizPageLoadSuccess(
          quiz: currentState.quiz,
          progress: newProgress,
          correctCount: counters['correct']!,
          incorrectCount: counters['incorrect']!,
          unansweredCount: counters['unanswered']!,
        ),
      );
    }
  }

  Future<QuizProgress> _loadProgress(String quizId) async {
    final key = 'quiz_progress_$quizId';
    final saved = prefs.getString(key);
    if (saved != null && saved.isNotEmpty) {
      // Use compute to run decoding in the background
      return await compute(_decodeQuizProgress, saved);
    }
    return QuizProgress(userAnswers: {}, correctness: {});
  }

  Future<void> _persistProgress(String quizId, QuizProgress progress) async {
    final key = 'quiz_progress_$quizId';
    // Use compute to run encoding in the background
    final jsonString = await compute(_encodeQuizProgress, progress);
    await prefs.setString(key, jsonString);
  }

  Map<String, int> _updateCounters(Quiz quiz, QuizProgress progress) {
    final correct = progress.correctness.values.where((v) => v).length;
    final incorrect = progress.correctness.values.where((v) => !v).length;
    final unanswered = quiz.questions.length - progress.userAnswers.length;
    return {
      'correct': correct,
      'incorrect': incorrect,
      'unanswered': unanswered,
    };
  }

  Future<void> _onGenerateNewQuestions(
    GenerateNewQuestions event,
    Emitter<QuizPageState> emit,
  ) async {
    if (state is! QuizPageLoadSuccess) return;

    final currentState = state as QuizPageLoadSuccess;
    emit(QuizPageGeneratingQuestions(quiz: currentState.quiz, progress: currentState.progress, correctCount: currentState.correctCount, incorrectCount: currentState.incorrectCount, unansweredCount: currentState.unansweredCount));

    try {
      final incorrectIndices = currentState.progress.correctness.entries
          .where((e) => e.value == false)
          .map((e) => e.key)
          .toList();
      final incorrectQuestions = incorrectIndices.map((i) {
        final q = currentState.quiz.questions[i];
        return {
          'index': i + 1,
          'question': q.question,
          if (q is MultipleChoiceQuizQuestion)
            'options': q.options.map((o) => o.text).toList(),
          'correctAnswer': q.answer,
          'userAnswer': currentState.progress.userAnswers[i],
        };
      }).toList();

      final progressSummary = {
        'incorrectQuestions': incorrectQuestions,
        'totalQuestions': currentState.quiz.questions.length,
        'correctCount': currentState.correctCount,
        'incorrectCount': currentState.incorrectCount,
        'unansweredCount': currentState.unansweredCount,
      };

      final userMessage = Content("user", [
        TextPart(
          "Here is my current quiz progress. Please focus on generating new questions that help me learn what I got wrong the most first.\n\nProgress (JSON):\n${jsonEncode(progressSummary)}${event.description != null && event.description!.trim().isNotEmpty ? "\n\nExtra instructions: ${event.description!.trim()}" : ""}",
        ),
      ]);

      final response = Inference.generateQuestions(userMessage);
      // TODO: Stream progress
      final newQuestions = await response.questions;

      final updatedQuiz = currentState.quiz..addQuestions(newQuestions);

      emit(QuizPageLoadSuccess(
        quiz: updatedQuiz,
        progress: currentState.progress, 
        correctCount: currentState.correctCount,
        incorrectCount: currentState.incorrectCount,
        unansweredCount: currentState.unansweredCount + newQuestions.length,
      ));
    } catch (e) {
      emit(QuizPageLoadFailure(e.toString()));
    }
  }
}
