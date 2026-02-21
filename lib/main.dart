import 'package:flutter/material.dart';
import 'screens/title_screen.dart';

void main() {
  runApp(const StroopApp());
}

class StroopApp extends StatelessWidget {
  const StroopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stroop',
      theme: ThemeData(useMaterial3: true),
      home: const TitleScreen(),
    );
  }
}
