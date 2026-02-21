import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/game_controller.dart';
import '../core/models.dart';
import '../widgets/judge_overlay.dart';
import '../widgets/pressable_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.onFinished,
  });

  final GameController controller;
  final VoidCallback onFinished;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _PolygonPainter extends CustomPainter {
  _PolygonPainter({
    required this.sides,
    required this.color,
    required this.cornerRadius,
  });

  final int sides; // 6 or 8
  final Color color;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 余白を入れて絶対にはみ出さないようにする
    final r = math.min(size.width, size.height) / 2 - 6;

    final raw = <Offset>[];
    final start = -math.pi / 2; // 上から開始
    for (int i = 0; i < sides; i++) {
      final a = start + (2 * math.pi * i / sides);
      raw.add(Offset(cx + r * math.cos(a), cy + r * math.sin(a)));
    }

    final path = _roundedPolygonPath(raw, cornerRadius);
    canvas.drawPath(path, paint);
  }

  Path _roundedPolygonPath(List<Offset> pts, double rad) {
    // 角丸の簡易版：各頂点の前後を少し内側にずらして二次曲線で繋ぐ
    final n = pts.length;
    final path = Path();

    Offset inset(Offset from, Offset to, double d) {
      final v = to - from;
      final len = v.distance;
      if (len == 0) return from;
      return from + v / len * d;
    }

    for (int i = 0; i < n; i++) {
      final prev = pts[(i - 1 + n) % n];
      final cur = pts[i];
      final next = pts[(i + 1) % n];

      final p1 = inset(cur, prev, rad);
      final p2 = inset(cur, next, rad);

      if (i == 0) {
        path.moveTo(p2.dx, p2.dy);
      } else {
        path.lineTo(p2.dx, p2.dy);
      }

      path.quadraticBezierTo(cur.dx, cur.dy, p1.dx, p1.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _PolygonPainter oldDelegate) =>
      oldDelegate.sides != sides ||
      oldDelegate.color != color ||
      oldDelegate.cornerRadius != cornerRadius;
}

class _GameScreenState extends State<GameScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
    widget.controller.start();
  }

  void _listener() {
    if (widget.controller.isFinished) {
      if (_navigated) return;
      _navigated = true;
      widget.onFinished();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.controller.current;
    if (q == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9), // クリーン寄りの薄グレーRf
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _miniHeader(context),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _prompt(q),
                            const SizedBox(height: 30),
                            _stroopCard(q),
                            const SizedBox(height: 80),
                            _choices(q),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          JudgeOverlay(
            isVisible: widget.controller.flashVisible,
            isCorrect: widget.controller.flashCorrect,
          ),
        ],
      ),
    );
  }

  Widget _miniHeader(BuildContext context) {
    final remain = widget.controller.remaining;
    final score = widget.controller.score.total;

    final remainStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: remain <= 10 ? Colors.red : Colors.black87,
    );

    return Row(
      children: [
        const SizedBox(width: 6),
        Text('残り ${remain}s', style: remainStyle),
        const Spacer(),
        Text(
          'スコア $score',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _prompt(StroopQuestion q) {
    final target = switch (q.questionType) {
      QuestionType.textColor => '文字の色',
      QuestionType.wordColor => '文字の内容',
      QuestionType.bgColor => '背景の色',
      QuestionType.unrelatedColor => 'どれでもない色',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '指示',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 20, color: Colors.black87),
              children: [
                TextSpan(
                  text: target,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const TextSpan(text: 'を選んで'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stroopCard(StroopQuestion q) {
    final shapeColor = q.bgColor == null ? Colors.white : q.bgColor!.uiBg;
    final textColor = q.textColor.ui;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(color: Colors.transparent),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _shapeWidget(q.level >= 4 ? q.shape : ShapeType.square, shapeColor),

          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                q.word,
                style: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                ),
              ),
              Text(
                q.word,
                style: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  color: q.textColor.ui,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shapeWidget(ShapeType shape, Color color) {
    switch (shape) {
      case ShapeType.square:
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
        );
      case ShapeType.circle:
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case ShapeType.hexagon:
        return CustomPaint(
          size: const Size(250, 250),
          painter: _PolygonPainter(sides: 6, color: color, cornerRadius: 14),
        );
      case ShapeType.octagon:
        return CustomPaint(
          size: const Size(250, 250),
          painter: _PolygonPainter(sides: 8, color: color, cornerRadius: 14),
        );
    }
  }

  Widget _choices(StroopQuestion q) {
    final colors = widget.controller.options;
    final isLevel5 = (q.level == 5);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _choice(colors[0], isLevel5)),
            const SizedBox(width: 12),
            Expanded(child: _choice(colors[1], isLevel5)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _choice(colors[2], isLevel5)),
            const SizedBox(width: 12),
            Expanded(child: _choice(colors[3], isLevel5)),
          ],
        ),
      ],
    );
  }

  Widget _choice(StroopColor c, bool level5Style) {
    if (level5Style) {
      return Pressable(
        onPressed: () => widget.controller.answer(c),
        child: Container(
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ],
          ),
          child: Text(
            widget.controller.optionLabel(c),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: c.ui,
            ),
          ),
        ),
      );
    }

    // 通常：色ボタン（黄色だけ文字を黒にして視認性改善）
    final fg = (c == StroopColor.yellow) ? Colors.black87 : Colors.white;

    return Pressable(
      onPressed: () => widget.controller.answer(c),
      child: Container(
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.ui,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ],
        ),
        child: Text(
          c.labelHira,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
      ),
    );
  }
}
