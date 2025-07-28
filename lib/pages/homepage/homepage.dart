import 'package:flutter/material.dart';
import 'package:midnight_v1/classes/app_data.dart';
import 'package:midnight_v1/pages/homepage/homepage_drawer.dart';
import 'package:midnight_v1/pages/homepage/main_title.dart';
import 'package:midnight_v1/pages/homepage/quiz_generation_container.dart';
import 'package:provider/provider.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final appData = Provider.of<AppData>(context);

    final isMobile = sizes.width < 600;
    return Scaffold(
      appBar: AppBar(),
      drawer: HomepageDrawer(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8.0 : 64.0,
            vertical: isMobile ? 8.0 : 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainTitle(),
              SizedBox(height: isMobile ? 16 : 32),
              QuizGenerationContainer(),
              SizedBox(
                width: sizes.width * (isMobile ? 0.95 : 0.6),
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 8 : 16),
                    ...appData.quizzes
                        .sublist(
                          (appData.quizzes.length < 3)
                              ? 0
                              : appData.quizzes.length - 3,
                          appData.quizzes.length,
                        )
                        .map(
                          (quiz) => TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).pushNamed("/quiz", arguments: quiz),
                            child: Text(quiz.title),
                          ),
                        )
                        .toList()
                        .reversed,
                    SizedBox(height: isMobile ? 8 : 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
