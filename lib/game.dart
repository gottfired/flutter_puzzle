import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pushtrix/audio.dart';
import 'package:pushtrix/background.dart';
import 'package:pushtrix/config.dart';
import 'package:pushtrix/countdown.dart';
import 'package:pushtrix/main.dart';
import 'package:pushtrix/save_game.dart';

import 'config.dart';
import 'game_time.dart';
import 'leaderboard.dart';
import 'puzzle.dart';

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

  int? transitionStarted;

  double levelTime = 0;
  double timeLeft = 0;

  CountdownState? _countDownState;
  MainState? _mainState;

  static late final Game instance;

  Game() {
    instance = this;
  }

  void start() {
    currentLevel = 0;
    startLevel();

    debugPrint("Game.start");
    transitionToState(GameState.playing);
  }

  void tick(double timeLeft) {
    final before = this.timeLeft;
    if (timeLeft < 4) {
      if (before.toInt() != timeLeft.toInt()) {
        Audio.instance.beep();
      }
    }
    this.timeLeft = timeLeft;
  }

  void move(int number) {
    puzzle?.move(number);
    if (puzzle?.isSolved() == true) {
      _countDownState?.solved();
      if (currentLevel > 5 && timeLeft < 2) {
        Audio.instance.thatWasClose();
      } else if (currentLevel > 5 && levelTime - timeLeft < 2 && (puzzle?.size ?? 0) > 2) {
        Audio.instance.tooEasy();
      } else {
        Audio.instance.praise();
      }
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
      return Random().nextDouble() - 0.5;
    }

    if (puzzleState == PuzzleState.dropIn) {
      return Random().nextDouble() * 0.2 - 0.1;
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

      if (state == GameState.playing) {
        Audio.instance.gameMusic();
      } else if (state == GameState.startScreen) {
        BackgroundState.instance.reset();
        Audio.instance.menuMusic();
      }
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
          const base = 4.0;
          // The more shuffleCount, the more time
          final shuffleBonus = shuffleCount ~/ 2;
          time = min(5.0, base + shuffleBonus);
          break;
        case 3:
          const base = 6.0;
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
    SaveGame.instance.saveLevel(currentLevel);
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
    timeLeft = levelTime;
    _countDownState?.start(levelTime);
  }

  void onTimerFinished() async {
    transitionToState(GameState.startScreen);
    SaveGame.instance.gameOver(currentLevel);
    Audio.instance.beepLong();
    Audio.instance.gameOver();
    int rank = await isHighScore(currentLevel);
    if (rank >= 0) {
      print("####### HIGH SCORE $rank");
      // TODO: trigger _mainState.highScore entry
    }
    _mainState?.redraw();
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

  void setCountdownState(CountdownState countdownState) {
    _countDownState = countdownState;
  }

  void setMainState(MainState mainState) {
    _mainState = mainState;
  }
}
