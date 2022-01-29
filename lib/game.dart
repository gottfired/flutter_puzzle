import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/config.dart';

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

  void start() {
    solved();
    state = GameState.playing;
  }

  void move(int number) {
    puzzle?.move(number);
  }

  bool isSolved() {
    return puzzle?.isSolved() ?? false;
  }

  double? puzzleTop(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (puzzle?.isSolved() == true) {
      return size.height / 2 + puzzle!.screenSize;
    } else if (dropIn) {
      return -size.height * 0.7;
    }

    return 0;
  }

  double puzzleRotation() {
    if (puzzle?.isSolved() == true || dropIn) {
      return Random().nextDouble() - 0.5;
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

  void solved() {
    final currentSize = sizeFromLevel();
    currentLevel++;
    final newSize = sizeFromLevel();
    if (newSize > currentSize) {
      currentShuffleCount = 1;
    }

    puzzle = Puzzle(newSize, currentShuffleCount);

    currentShuffleCount++;
  }
}
