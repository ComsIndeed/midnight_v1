import 'package:flutter/material.dart';
import 'package:midnight_v1/pages/homepage/homepage_action_field.dart';
import 'package:midnight_v1/pages/homepage/homepage_drawer.dart';
import 'package:midnight_v1/pages/homepage/main_title.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final isMobile = sizes.width < 600;

    return Scaffold(
      appBar: AppBar(),
      drawer: const HomepageDrawer(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8.0 : 64.0,
            vertical: isMobile ? 8.0 : 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainTitle(size: isMobile ? 0.75 : 1),
              SizedBox(height: isMobile ? 16 : 32),
              HomepageActionField(),
            ],
          ),
        ),
      ),
    );
  }
}
