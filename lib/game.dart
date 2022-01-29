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

  int currentPuzzleSize = 2;
  int currentLevel = 1;

  bool dropIn = false;

  void start() {
    puzzle = Puzzle(currentPuzzleSize);
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

  void solved() {
    currentLevel++;
    if (alwaysSmallPuzzles) {
      currentPuzzleSize = 2;
    } else {
      currentPuzzleSize = 2 + currentLevel ~/ 4;
    }

    puzzle = Puzzle(currentPuzzleSize);
  }
}
