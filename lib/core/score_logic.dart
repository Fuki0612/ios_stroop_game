class ScoreState {
  int correct = 0;
  int bonus = 0;
  int streak = 0;

  int get total => correct + bonus;

  void onCorrect() {
    correct += 1;
    streak += 1;
    bonus += (streak ~/ 5);
  }

  void onWrong() {
    streak = 0;
  }
}
