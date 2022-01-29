import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/config.dart';
import 'dart:async';
import 'puzzle.dart';

enum GameState {
  startScreen,
  playing,
  gameOver,
}

class Game {
  Puzzle? puzzle;
  GameState state = GameState.startScreen;

  int currentLevel = 0;
  int currentShuffleCount = 1;

  bool dropIn = false;

  Timer? _timer;
  double _timerValue = 0;

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

    if (puzzle?.isSolved() == true) {
      return size.height / 2 + getPuzzleScreenSize();
    } else if (dropIn) {
      return -size.height * 0.8;
    }

    return 0;
  }

  double puzzleRotation() {
    if (puzzle?.isSolved() == true) {
      return Random().nextDouble() * 3 - 1.5;
    }

    if (dropIn) {
      final v = Random().nextDouble() - 0.5;
      return v + v.sign;
    }

    return 0;
  }

  void reset() {
    puzzle = null;
    dropIn = true;
  }

  bool isResetting() {
    return puzzle == null && dropIn;
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

    _timerValue = 10;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (Timer timer) {
        if (_timerValue <= 0) {
          timer.cancel();
          state = GameState.gameOver;
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
    return state == GameState.playing && !isResetting() && !dropIn && !isSolved();
  }
}
