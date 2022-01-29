import 'puzzle.dart';

enum GameState {
  startScreen,
  playing,
  gameOver,
}

class Game {
  Puzzle? puzzle;
  GameState state = GameState.startScreen;

  int currentPuzzleSize = 2;
  int currentLevel = 1;

  void start() {
    puzzle = Puzzle(currentPuzzleSize);
    state = GameState.playing;
  }

  void move(int number) {
    final p = puzzle;
    if (p == null) {
      return;
    }

    p.move(number);
    if (p.isSolved()) {
      solved();
    }
  }

  void solved() {
    currentLevel++;
    currentPuzzleSize = 2 + currentLevel ~/ 4;
    puzzle = Puzzle(currentPuzzleSize);
  }
}
