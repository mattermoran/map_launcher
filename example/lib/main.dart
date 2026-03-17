import 'package:flutter/material.dart';

import 'home_page.dart';
import 'theme.dart';

void main() => runApp(const MapLauncherExample());

class MapLauncherExample extends StatelessWidget {
  const MapLauncherExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Launcher',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
