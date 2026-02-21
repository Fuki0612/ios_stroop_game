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

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
    widget.controller.start();
  }

  void _listener() {
    if (widget.controller.isFinished) {
      widget.onFinished();
    } else {
      setState(() {});
    }
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

    final level = widget.controller.level;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9), // クリーン寄りの薄グレーRf
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                children: [
                  _miniHeader(context),
                  const SizedBox(height: 10),

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
    // 強調したい対象語だけを太く
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
    final bg = q.bgColor == null ? Colors.white : q.bgColor!.ui;
    final textColor = q.textColor.ui;

    return Container(
      width: 250,
      height: 220,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Text(
          q.word,
          style: TextStyle(
            fontSize: 58,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _choices(StroopQuestion q) {
    final colors = StroopColor.values.toList();

    // レベル1-3は固定順，4以降シャッフル
    if (q.level >= 4) {
      colors.shuffle();
    }

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
      // 白背景＋色文字（黄色は暗め）
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
            c.labelHira,
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
