import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/config.dart';
import 'dart:async';
import 'puzzle.dart';
import 'config.dart';

enum GameState {
  startScreen,
  playing,
}

enum PuzzleState {
  dropIn,
  playing,
  dropOut,
}

class Game {
  Puzzle? puzzle;
  GameState state = GameState.startScreen;
  GameState? nextState;

  int currentLevel = 0;

  PuzzleState puzzleState = PuzzleState.playing;

  Timer? _timer;
  double _timerValue = 0;

  int? transitionStarted;

  double levelTime = 0;

  static late final Game instance;

  Game() {
    instance = this;
  }

  Function(double value)? onTimerTick;

  void start(Function(double value)? onTimerTick) {
    currentLevel = 0;
    startLevel();
    this.onTimerTick = onTimerTick;

    debugPrint("Game.start");

    transitionToState(GameState.playing);
  }

  void move(int number) {
    puzzle?.move(number);
    if (puzzle?.isSolved() == true) {
      _timer?.cancel();
    }
  }

  bool isSolved() {
    return puzzle?.isSolved() ?? false;
  }

  double? puzzleTop(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (puzzleState == PuzzleState.dropOut) {
      return size.height / 2 + getPuzzleScreenSize();
    }

    if (puzzleState == PuzzleState.dropIn) {
      return -size.height * 0.8;
    }

    return 0;
  }

  double puzzleRotation() {
    if (puzzleState == PuzzleState.dropOut) {
      return Random().nextDouble() * 2 - 1;
    }

    if (puzzleState == PuzzleState.dropIn) {
      final v = Random().nextDouble() - 0.5;
      return v + v.sign;
    }

    return 0;
  }

  void reset() {
    puzzle = null;
    puzzleState = PuzzleState.dropIn;
  }

  bool isResetting() {
    return puzzle == null && puzzleState == PuzzleState.dropIn;
  }

  void transitionToState(GameState state) {
    nextState = state;
    transitionStarted = DateTime.now().millisecondsSinceEpoch;
  }

  void performTransition() {
    if (nextState != null) {
      state = nextState!;
      nextState = null;
    }
  }

  int _sizeFromLevel() {
    if (alwaysSmallPuzzles) {
      return 2;
    }

    if (currentLevel < 3) {
      return 2;
    } else if (currentLevel < 6) {
      return Random().nextBool() ? 2 : 3;
    } else if (currentLevel < 9) {
      return Random().nextInt(3) == 0 ? 2 : 3;
    } else if (currentLevel < 12) {
      final dice = Random().nextInt(6);
      if (dice == 0) {
        return 2;
      } else if (dice < 4) {
        return 3;
      } else {
        return 4;
      }
    } else {
      final dice = Random().nextInt(10);
      if (dice == 0) {
        return 2;
      } else if (dice < 4) {
        return 3;
      } else {
        return 4;
      }
    }
  }

  double _calculateLevelTime(int size, int shuffleCount) {
    if (infiniteTime) {
      return 1000.0;
    } else {
      var time = 20.0;
      switch (size) {
        case 2:
          // Smaller puzzles are easier
          const base = 3.0;
          // The more shuffleCount, the more time
          final shuffleBonus = shuffleCount ~/ 2;
          time = min(4.0, base + shuffleBonus);
          break;
        case 3:
          const base = 5.0;
          final shuffleBonus = shuffleCount ~/ 2;
          time = min(15.0, base + shuffleBonus);
          break;
        case 4:
          const base = 8.0;
          final shuffleBonus = shuffleCount;
          time = min(60.0, base + shuffleBonus);
          break;
      }

      // Make first few levels easier
      final levelBonus = max(0, (4 - currentLevel / 2));

      return time + levelBonus;
    }
  }

  void startLevel() {
    currentLevel++;
    final newSize = _sizeFromLevel();

    int shuffle = 0;
    if (newSize == 2) {
      shuffle = 1 + (currentLevel ~/ 2);
    } else if (newSize == 3) {
      shuffle = 1 + (currentLevel ~/ 2.5);
    } else {
      shuffle = 1 + (currentLevel ~/ 3);
    }

    // debugPrint("New puzzle size: $newSize, shuffleCount $shuffle");
    puzzle = Puzzle(newSize, shuffle);

    levelTime = _calculateLevelTime(newSize, shuffle);
    _timerValue = levelTime;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (Timer timer) {
        if (_timerValue <= 0) {
          timer.cancel();
          transitionToState(GameState.startScreen);
        } else {
          _timerValue -= 0.01;
          if (_timerValue < 0) {
            _timerValue = 0;
          }
        }

        onTimerTick?.call(_timerValue);
      },
    );
  }

  double getPuzzleScreenSize() {
    return puzzle != null ? Puzzle.getScreenSize(puzzle!.size) : 0;
  }

  bool showCountdown() {
    return state == GameState.playing && !isResetting() && puzzleState != PuzzleState.dropIn && !isSolved();
  }

  void dropOut() {
    puzzleState = PuzzleState.dropOut;
  }
}
