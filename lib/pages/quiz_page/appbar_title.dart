import 'package:flutter/material.dart';
import 'package:midnight_v1/classes/quiz.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({super.key, required this.quiz});

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.dark_mode),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            "Midnight: ${quiz.title}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
