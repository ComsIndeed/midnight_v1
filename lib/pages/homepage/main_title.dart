import 'package:flutter/material.dart';

class MainTitle extends StatelessWidget {
  const MainTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.dark_mode, size: 64),
        SizedBox(width: 4),
        Text(
          "Midnight",
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.displayLarge?.fontSize,
          ),
        ),
      ],
    );
  }
}
