import 'package:flutter/material.dart';

enum StroopColor { red, blue, yellow, green }

extension StroopColorX on StroopColor {
  String get labelHira => switch (this) {
    StroopColor.red => 'あか',
    StroopColor.blue => 'あお',
    StroopColor.yellow => 'きいろ',
    StroopColor.green => 'みどり',
  };

  String get labelKata => switch (this) {
    StroopColor.red => 'アカ',
    StroopColor.blue => 'アオ',
    StroopColor.yellow => 'キイロ',
    StroopColor.green => 'ミドリ',
  };

  String get labelKanji => switch (this) {
    StroopColor.red => '赤',
    StroopColor.blue => '青',
    StroopColor.yellow => '黄',
    StroopColor.green => '緑',
  };

  Color get ui => switch (this) {
    StroopColor.red => Colors.red,
    StroopColor.blue => Colors.blue,
    StroopColor.yellow => Colors.amber.shade800,
    StroopColor.green => Colors.green,
  };

  Color get uiBg => switch (this) {
    StroopColor.red => Colors.red.shade200,
    StroopColor.blue => Colors.blue.shade200,
    StroopColor.yellow => Colors.amber.shade200,
    StroopColor.green => Colors.green.shade200,
  };
}
