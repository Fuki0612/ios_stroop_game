import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'question_generator.dart';
import 'score_logic.dart';
import 'colors.dart';

class GameController extends ChangeNotifier {
  GameController({required this.level, required this.generator});

  final int level;
  final QuestionGenerator generator;

  static const gameSeconds = 60;

  final score = ScoreState();

  StroopQuestion? current;
  int remaining = gameSeconds;

  bool flashVisible = false;
  bool flashCorrect = true;

  bool isFinished = false;

  Timer? _timer;

  void start() {
    isFinished = false;
    remaining = gameSeconds;
    score.correct = 0;
    score.bonus = 0;
    score.streak = 0;

    current = generator.next(level);
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {});

    // 秒単位のカウントダウン
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining -= 1;
      if (remaining <= 0) {
        remaining = 0;
        finish();
      } else {
        notifyListeners();
      }
    });
  }

  void answer(StroopColor choice) {
    if (isFinished || current == null) return;

    final correct = (choice == current!.correctColor);

    if (correct) {
      score.onCorrect();
    } else {
      score.onWrong();
    }

    // 〇/×を一瞬出す
    _flash(correct);

    // 次の問題
    current = generator.next(level);
    notifyListeners();
  }

  void _flash(bool correct) {
    flashCorrect = correct;
    flashVisible = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 650), () {
      flashVisible = false;
      notifyListeners();
    });
  }

  void finish() {
    if (isFinished) return;
    isFinished = true;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
