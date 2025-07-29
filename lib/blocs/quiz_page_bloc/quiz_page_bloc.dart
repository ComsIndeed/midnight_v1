import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/pages/quiz_page/quiz_page.dart';
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
  }

  Future<void> _onLoadQuizProgress(
    LoadQuizProgress event,
    Emitter<QuizPageState> emit,
  ) async {
    emit(QuizPageLoadInProgress());
    try {
      final progress = await _loadProgress(event.quiz.title);
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

      await _persistProgress(currentState.quiz.title, newProgress);
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

  Future<QuizProgress> _loadProgress(String quizTitle) async {
    final key = 'quiz_progress_$quizTitle';
    final saved = prefs.getString(key);
    if (saved != null && saved.isNotEmpty) {
      // Use compute to run decoding in the background
      return await compute(_decodeQuizProgress, saved);
    }
    return QuizProgress(userAnswers: {}, correctness: {});
  }

  Future<void> _persistProgress(String quizTitle, QuizProgress progress) async {
    final key = 'quiz_progress_$quizTitle';
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
}
