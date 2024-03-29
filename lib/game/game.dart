import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pushtrix/audio.dart';
import 'package:pushtrix/background.dart';
import 'package:pushtrix/config.dart';
import 'package:pushtrix/game/countdown.dart';
import 'package:pushtrix/main.dart';
import 'package:pushtrix/game/save_game.dart';

import '../config.dart';
import '../leaderboard.dart';
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

const levelNewbie = 3;
const levelEasy = 6;
const levelMedium = 9;
const levelHard = 12;
const levelInsane = 50;

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

  int _calculatePuzzleSize() {
    if (alwaysSmallPuzzles) {
      return 2;
    }

    if (currentLevel < levelNewbie) {
      // Level < 3 -> puzzle size is 2
      return 2;
    } else if (currentLevel < levelEasy) {
      // Level < 6 -> 50% are 2, 50% are 3
      return Random().nextBool() ? 2 : 3;
    } else if (currentLevel < levelMedium) {
      // Level < 9 -> 33% are 2, 66% are 3
      return Random().nextInt(3) == 0 ? 2 : 3;
    } else if (currentLevel < levelHard) {
      // Level < 9 -> 1/6 are 2, 3/6 are 3, 2/6 are 4
      final dice = Random().nextInt(6);
      if (dice == 0) {
        return 2;
      } else if (dice < 4) {
        return 3;
      } else {
        return 4;
      }
    } else if (currentLevel < levelInsane) {
      // 1/10 are 2, 3/10 are 3, 6/10 are 4
      final dice = Random().nextInt(10);
      if (dice == 0) {
        return 2;
      } else if (dice < 4) {
        return 3;
      } else {
        return 4;
      }
    } else {
      // 1/20 are 2, 3/20 are 3, 16/20 are 4
      final dice = Random().nextInt(20);
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
          time = min(currentLevel > levelInsane ? 3.0 : 5.0, base + shuffleBonus);
          break;
        case 3:
          const base = 6.0;
          final shuffleBonus = shuffleCount ~/ 2;
          time = min(currentLevel > levelInsane ? 10.0 : 15.0, base + shuffleBonus);
          break;
        case 4:
          const base = 8.0;
          final shuffleBonus = shuffleCount;

          // Once you've reached levelInsane -> decrease max time
          var maxTimeSeconds = 60.0;
          if (currentLevel > levelInsane) {
            final delta = currentLevel - levelInsane;
            maxTimeSeconds -= delta ~/ 2;
            if (maxTimeSeconds < 20) {
              maxTimeSeconds = 20;
            }
          }

          time = min(maxTimeSeconds, base + shuffleBonus);
          break;
      }

      // Make first few levels easier
      final levelBonus = max(0, (4 - currentLevel / 2));

      return time + levelBonus;
    }
  }

  int _calculateShuffleCount(int newSize) {
    int shuffle = 0;
    if (newSize == 2) {
      shuffle = 1 + (currentLevel ~/ 2);
    } else if (newSize == 3) {
      shuffle = 1 + (currentLevel ~/ 2.5);
    } else {
      if (currentLevel > levelInsane) {
        // Starting from level insane gradually go from currentLevel/3 to currentLevel
        final delta = (currentLevel - levelInsane) ~/ 30;
        shuffle = 1 + (currentLevel ~/ max(1, (3 - delta)));
      } else {
        shuffle = 1 + (currentLevel ~/ 3);
      }
    }

    return shuffle;
  }

  void startLevel() {
    currentLevel++;

    // Record personal best for highest level reached
    SaveGame.instance.saveLevel(currentLevel);

    // Now determine how difficult this level will be
    // - size
    // - how many shuffle moves
    // - how much time
    final newSize = _calculatePuzzleSize();
    int shuffle = _calculateShuffleCount(newSize);
    levelTime = _calculateLevelTime(newSize, shuffle);

    // Create the puzzle
    puzzle = Puzzle(newSize, shuffle);

    // Start the level
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
      _mainState?.showHighscoreDialog(rank, currentLevel);
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

  void pause() {
    if (state == GameState.playing) {
      _countDownState?.stopTimer();
    }

    BackgroundState.instance.pause();
  }

  void resume() {
    if (state == GameState.playing) {
      _countDownState?.startTimer();
    }

    BackgroundState.instance.resume();
  }
}
