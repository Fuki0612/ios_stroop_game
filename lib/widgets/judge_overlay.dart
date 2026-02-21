import 'package:flutter/material.dart';

class JudgeOverlay extends StatelessWidget {
  const JudgeOverlay({
    super.key,
    required this.isVisible,
    required this.isCorrect,
  });

  final bool isVisible;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final symbol = isCorrect ? '○' : '×';
    final color = isCorrect ? Colors.blue : Colors.red;

    return Positioned(
      top: 165,
      right: 22,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: 72, // 円に固定するため正方形
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle, // ←ここが本命
              color: Colors.white.withValues(alpha: 0.92),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ],
            ),
            child: Text(
              symbol,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
