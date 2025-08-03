import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:midnight_v1/blocs/quiz_page_bloc/quiz_page_bloc.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/classes/app_prefs.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/pages/chats_page/chats_page.dart';
import 'package:midnight_v1/pages/homepage/homepage.dart';
import 'package:midnight_v1/pages/quiz_page/quiz_page.dart';
import 'package:midnight_v1/pages/settings_page/settings_page.dart';
import 'package:midnight_v1/pages/study_page/study_page.dart';
import 'package:midnight_v1/repositories/quiz_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  final prefs = await AppPrefs().init();
  final quizRepository = QuizRepository(prefs);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: quizRepository),
        RepositoryProvider.value(value: prefs),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                QuizzesBloc(context.read<QuizRepository>())..add(LoadQuizzes()),
          ),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => const Homepage(),
        "/study": (context) => const StudyPage(),
        "/chats": (context) => const ChatsPage(),
        "/settings": (context) => const SettingsPage(),
        "/quiz": (context) {
          final quiz = ModalRoute.of(context)?.settings.arguments as Quiz;
          return BlocProvider(
            create: (context) =>
                QuizPageBloc(context.read<SharedPreferences>())
                  ..add(LoadQuizProgress(quiz)),
            child: QuizPage(quiz: quiz),
          );
        },
      },
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
        child: child!,
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}
