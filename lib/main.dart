import 'package:flutter/material.dart';
import 'core/question_generator.dart';
import 'core/game_controller.dart';
import 'screens/game_screen.dart';

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
      home: const _QuickStart(),
    );
  }
}

class _QuickStart extends StatelessWidget {
  const _QuickStart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('クイック起動（仮）')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final controller = GameController(
              level: 1,
              generator: QuestionGenerator(),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  controller: controller,
                  onFinished: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: const Text('レベル1で開始'),
        ),
      ),
    );
  }
}
