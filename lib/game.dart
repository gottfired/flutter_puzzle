import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/config.dart';
import 'dart:async';
import 'puzzle.dart';
import 'config.dart';

enum GameState {
  startScreen,
  playing,
  gameOver,
}

enum PuzzleState {
  dropIn,
  playing,
  dropOut,
}

class Game {
  Puzzle? puzzle;
  GameState state = GameState.startScreen;

  int currentLevel = 0;
  int currentShuffleCount = 1;

  PuzzleState puzzleState = PuzzleState.playing;

  Timer? _timer;
  double _timerValue = 0;

  int gameOverTime = 0;

  static late final Game instance;

  Game() {
    instance = this;
  }

  Function(double value)? onTimerTick;

  void start(Function(double value)? onTimerTick) {
    currentLevel = 0;
    currentShuffleCount = 1;

    startLevel();
    state = GameState.playing;
    this.onTimerTick = onTimerTick;
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

  void _gameOver() {
    state = GameState.gameOver;
    gameOverTime = DateTime.now().millisecondsSinceEpoch;
  }

  int sizeFromLevel() {
    if (alwaysSmallPuzzles) {
      return 2;
    }

    const sizeIncreaseAtLevel = 9;
    const maxSize = 4;
    return min(2 + currentLevel ~/ sizeIncreaseAtLevel, maxSize);
  }

  void startLevel() {
    final currentSize = sizeFromLevel();
    currentLevel++;
    final newSize = sizeFromLevel();
    if (newSize > currentSize) {
      currentShuffleCount = 1;
    }

    debugPrint("New puzzle size: $newSize, shuffleCount $currentShuffleCount");
    puzzle = Puzzle(newSize, currentShuffleCount);

    currentShuffleCount++;

    _timerValue = levelDurationSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (Timer timer) {
        if (_timerValue <= 0) {
          timer.cancel();
          _gameOver();
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
