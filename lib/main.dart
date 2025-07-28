import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:midnight_v1/classes/app_data.dart';
import 'package:midnight_v1/classes/app_prefs.dart';
import 'package:midnight_v1/classes/quiz.dart';
import 'package:midnight_v1/pages/homepage/homepage.dart';
import 'package:midnight_v1/pages/quiz_page/quiz_page.dart';
import 'package:midnight_v1/pages/settings_page/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  final prefs = await AppPrefs().init();
  final appData = AppData(prefs);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: appData)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => Homepage(),
        "/settings": (context) => SettingsPage(),
        "/quiz": (context) {
          final quiz = ModalRoute.of(context)?.settings.arguments as Quiz;
          return QuizPage(quiz: quiz);
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
