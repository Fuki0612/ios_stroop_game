import 'colors.dart';

enum WordForm { hira, kata, kanji }

enum ShapeType { square, triangle, circle }

enum QuestionType { textColor, wordColor, bgColor, unrelatedColor }

class StroopQuestion {
  StroopQuestion({
    required this.level,
    required this.prompt,
    required this.bgColor, // null means white
    required this.shape,
    required this.textColor,
    required this.wordColor,
    required this.wordForm,
    required this.questionType,
    required this.correctColor,
  });

  final int level;
  final String prompt;
  final StroopColor? bgColor;
  final ShapeType shape;
  final StroopColor textColor;
  final StroopColor wordColor;
  final WordForm wordForm;
  final QuestionType questionType;
  final StroopColor correctColor;

  String get word => switch (wordForm) {
    WordForm.hira => wordColor.labelHira,
    WordForm.kata => wordColor.labelKata,
    WordForm.kanji => wordColor.labelKanji,
  };
}
