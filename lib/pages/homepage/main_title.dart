import 'package:flutter/material.dart';

class MainTitle extends StatelessWidget {
  const MainTitle({
    super.key,
    this.size = 1,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final double size;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.displayLarge?.fontSize;
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Icon(Icons.dark_mode, size: 64 * size),
        SizedBox(width: 4),
        Text(
          "Midnight ",
          style: TextStyle(fontSize: fontSize != null ? fontSize * size : 64),
        ),
      ],
    );
  }
}
