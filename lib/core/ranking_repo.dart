import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RankingRepo {
  static const _keep = 30;

  String _key(int level) => 'ranking_v1_level_$level';

  Future<List<int>> loadScores(int level) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(level));
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => (e['score'] as num).toInt()).toList();
  }

  Future<void> addScore(int level, int score) async {
    final scores = await loadScores(level);
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a));
    final trimmed = scores.take(_keep).toList();

    final sp = await SharedPreferences.getInstance();
    final json = jsonEncode(trimmed.map((s) => {'score': s}).toList());
    await sp.setString(_key(level), json);
  }

  /// Top5を「同点同順位」で整形して返す
  Future<List<RankLine>> top5WithTies(int level) async {
    final scores = await loadScores(level);
    final top = scores.take(5).toList();

    final out = <RankLine>[];
    int rank = 1;
    for (int i = 0; i < top.length; i++) {
      if (i > 0 && top[i] != top[i - 1]) {
        rank = i + 1;
      }
      out.add(RankLine(rank: rank, score: top[i]));
    }
    return out;
  }
}

class RankLine {
  RankLine({required this.rank, required this.score});
  final int rank;
  final int score;
}
