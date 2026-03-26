import 'package:flutter/material.dart';
import 'screens/title_screen.dart';

void main() => runApp(const StroopApp());

class StroopApp extends StatelessWidget {
  const StroopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Stroop Max',
      theme: theme,
      home: const TitleScreen(),
    );
  }
}
