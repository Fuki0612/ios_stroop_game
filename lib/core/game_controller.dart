import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'colors.dart';
import 'models.dart';
import 'question_generator.dart';
import 'score_logic.dart';

class GameController extends ChangeNotifier {
  GameController({required this.level, required this.generator})
    : _r = Random();

  final int level;
  final QuestionGenerator generator;
  final Random _r;

  static const gameSeconds = 60;

  final score = ScoreState();

  StroopQuestion? current;
  int remaining = gameSeconds;

  bool flashVisible = false;
  bool flashCorrect = true;

  bool isFinished = false;

  List<StroopColor> options = StroopColor.values;
  final Map<StroopColor, WordForm> _optionForms = {};
  final Map<StroopColor, StroopColor> _optionWordMeaning = {};

  Timer? _timer;

  void start() {
    isFinished = false;
    remaining = gameSeconds;
    score.correct = 0;
    score.bonus = 0;
    score.streak = 0;

    current = generator.next(level);
    _refreshOptions();
    notifyListeners();

    _timer?.cancel();
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

    _flash(correct);

    current = generator.next(level);
    _refreshOptions();
    notifyListeners();
  }

  void _refreshOptions() {
    final base = StroopColor.values.toList();

    if (level >= 4) {
      base.shuffle(_r);
    }
    options = base;

    _optionForms.clear();
    _optionWordMeaning.clear();

    if (level == 5) {
      for (final c in options) {
        _optionForms[c] = WordForm.values[_r.nextInt(WordForm.values.length)];

        final others = StroopColor.values.where((x) => x != c).toList();
        _optionWordMeaning[c] = others[_r.nextInt(others.length)];
      }
    }
  }

  String optionLabel(StroopColor choiceColor) {
    final form = _optionForms[choiceColor] ?? WordForm.hira;
    final meaning = _optionWordMeaning[choiceColor] ?? choiceColor;

    return switch (form) {
      WordForm.hira => meaning.labelHira,
      WordForm.kata => meaning.labelKata,
      WordForm.kanji => meaning.labelKanji,
    };
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
