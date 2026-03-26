import 'package:flutter/material.dart';
import '../core/ranking_repo.dart';
import '../widgets/app_card.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final repo = RankingRepo();
  final Map<int, List<RankLine>> data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (int level = 1; level <= 5; level++) {
      data[level] = await repo.top3WithTies(level); // ★ここ
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('記録')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _headerRow(),
              const SizedBox(height: 10),
              for (int level = 1; level <= 5; level++) ...[
                Expanded(
                  child: _levelRow(level: level, lines: data[level]),
                ),
                if (level != 5) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerRow() {
    const gold = Color(0xFFD4AF37);
    const silver = Color(0xFFC0C0C0);
    const bronze = Color(0xFFCD7F32);

    TextStyle s(Color c) => TextStyle(fontWeight: FontWeight.w900, color: c);

    return Row(
      children: [
        const SizedBox(
          width: 56,
          child: Text(
            'Lv',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(child: Text('1位', style: s(gold))),
              ),
              Expanded(
                child: Center(child: Text('2位', style: s(silver))),
              ),
              Expanded(
                child: Center(child: Text('3位', style: s(bronze))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _levelRow({required int level, required List<RankLine>? lines}) {
    // top3WithTiesが返す想定：最大3件
    final cells = List<String>.filled(3, '-');
    if (lines != null) {
      for (int i = 0; i < lines.length && i < 3; i++) {
        cells[i] = '${lines[i].score}';
      }
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              'Lv$level',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: (lines == null)
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : Row(
                    children: [
                      _rankCell(cells[0], emphasize: true),
                      _rankCell(cells[1]),
                      _rankCell(cells[2]),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rankCell(String text, {bool emphasize = false}) {
    return Expanded(
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: emphasize
              ? Colors.black.withValues(alpha: 0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: emphasize ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
