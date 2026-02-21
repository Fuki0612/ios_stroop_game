import 'dart:math';
import 'colors.dart';
import 'models.dart';

class QuestionGenerator {
  QuestionGenerator({Random? random}) : _r = random ?? Random();

  final Random _r;
  final _colors = StroopColor.values;

  StroopQuestion next(int level) {
    for (int attempt = 0; attempt < 50; attempt++) {
      final questionType = _pickQuestionType(level);

      StroopColor? bg = (level == 1) ? null : _pickColor();
      ShapeType shape = (level >= 4) ? _pickShape() : ShapeType.square;
      WordForm form = (level >= 4) ? _pickForm() : WordForm.hira;

      StroopColor textColor = _pickColor();
      StroopColor wordColor = _pickColor();

      // 背景色と文字色を一致させない
      if (level >= 2 && bg != null && textColor == bg) {
        continue;
      }

      // unrelatedは成立させるために3色をユニークに強制
      if (questionType == QuestionType.unrelatedColor) {
        final picked = _pickDistinct3();
        bg = picked[0];
        textColor = picked[1];
        wordColor = picked[2];
      }

      if (questionType == QuestionType.bgColor && level == 1) {
        continue;
      }

      final correct = _resolveCorrect(questionType, bg, textColor, wordColor);
      final prompt = switch (questionType) {
        QuestionType.textColor => '文字の色を選んで',
        QuestionType.wordColor => '文字の内容を選んで',
        QuestionType.bgColor => '背景の色を選んで',
        QuestionType.unrelatedColor => 'どれでもない色を選んで',
      };

      return StroopQuestion(
        level: level,
        prompt: prompt,
        bgColor: bg,
        shape: shape,
        textColor: textColor,
        wordColor: wordColor,
        wordForm: form,
        questionType: questionType,
        correctColor: correct,
      );
    }

    return next(level);
  }

  QuestionType _pickQuestionType(int level) {
    final roll = _r.nextInt(100);

    if (level == 1) {
      return (roll < 50) ? QuestionType.textColor : QuestionType.wordColor;
    }

    if (level == 2) {
      if (roll < 33) return QuestionType.textColor;
      if (roll < 66) return QuestionType.wordColor;
      return QuestionType.bgColor;
    }

    if (roll < 25) return QuestionType.unrelatedColor;
    if (roll < 50) return QuestionType.textColor;
    if (roll < 75) return QuestionType.wordColor;
    return QuestionType.bgColor;
  }

  StroopColor _pickColor() => _colors[_r.nextInt(_colors.length)];

  ShapeType _pickShape() {
    final v = ShapeType.values;
    return v[_r.nextInt(v.length)];
  }

  WordForm _pickForm() {
    final v = WordForm.values;
    return v[_r.nextInt(v.length)];
  }

  List<StroopColor> _pickDistinct3() {
    final shuffled = [..._colors]..shuffle(_r);
    return [shuffled[0], shuffled[1], shuffled[2]];
  }

  StroopColor _resolveCorrect(
    QuestionType type,
    StroopColor? bg,
    StroopColor text,
    StroopColor word,
  ) {
    return switch (type) {
      QuestionType.textColor => text,
      QuestionType.wordColor => word,
      QuestionType.bgColor => bg!,
      QuestionType.unrelatedColor => _colors.firstWhere(
        (c) => c != bg && c != text && c != word,
      ),
    };
  }
}
