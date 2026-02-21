import 'package:flutter/material.dart';
import '../core/question_generator.dart';
import '../core/game_controller.dart';
import '../core/ranking_repo.dart';
import 'game_screen.dart';
import 'result_screen.dart';
import 'records_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F7F9);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Stroop',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                '60秒でどれだけ正解できるか',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int level = 1; level <= 5; level++) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _startLevel(context, level),
                              child: Text('レベル $level'),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RecordsScreen(),
                                ),
                              );
                            },
                            child: const Text('記録を見る'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLevel(BuildContext context, int level) {
    final controller = GameController(
      level: level,
      generator: QuestionGenerator(),
    );
    final repo = RankingRepo();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          controller: controller,
          onFinished: () async {
            final total = controller.score.total;
            await repo.addScore(level, total);

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(level: level, score: total),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
