import 'package:flutter/material.dart';
import 'package:midnight_v1/pages/homepage/homepage_drawer.dart';
import 'package:midnight_v1/pages/homepage/main_title.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainTitle(size: 0.5, mainAxisAlignment: MainAxisAlignment.start),
      ),
      drawer: HomepageDrawer(),
      body: Center(child: Column(children: [])),
    );
  }
}
