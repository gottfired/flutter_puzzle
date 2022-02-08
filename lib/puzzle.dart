import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/config.dart';

class Puzzle {
  final List<int> tiles = [];
  List<int> lastTiles = [];
  final List<int> _empty;
  final int size;
  double _animTime = 0;

  static double getScreenSize(int puzzleHeight) {
    return puzzleHeight * tileSize + 2 * puzzleBorderSize;
  }

  double get screenSize {
    return size * tileSize + 2 * puzzleBorderSize;
  }

  Puzzle(this.size, int shuffleCount) : _empty = [size - 1, size - 1] {
    reset();

    if (shuffleCount > 0) {
      while (isSolved()) {
        reset();
        shuffle(shuffleCount);
      }
    }
  }

  void reset() {
    tiles.clear();
    for (int i = 0; i < size * size - 1; i++) {
      tiles.add(i + 1);
    }

// Empty is marked with 0
    tiles.add(0);
  }

  void shuffle(int shuffleCount) {
    for (var i = 0; i < shuffleCount; ++i) {
      doRandomMove();
    }
  }

  void move(int number) {
    if (number <= 0 || number > size * size - 1) {
      return;
    }

    // find coords of number
    final coords = _getCoords(number);
    final x = coords[0];
    final y = coords[1];

    if (x == _empty[0]) {
      _moveColumn(y);
      _debugOutput();
    } else if (y == _empty[1]) {
      _moveRow(x);
      _debugOutput();
    }
  }

  bool isSolved() {
    for (int i = 0; i < size * size - 1; i++) {
      if (tiles[i] != i + 1) {
        return false;
      }
    }

    return true;
  }

  void _startTileMoveAnim() {
    lastTiles = tiles.toList(growable: false);
    _animTime = 0;
  }

  void tickTileMoveAnim(double dt) {
    _animTime += dt * 5;
  }

  Offset getTileOffset(int number) {
    final coords = _getCoords(number);
    if (_animTime >= 1) {
      return Offset(coords[0] * tileSize + puzzleBorderSize, coords[1] * tileSize + puzzleBorderSize);
    }

    final lastCoords = _getCoords(number, true);
    final lastX = lastCoords[0];
    final lastY = lastCoords[1];

    if (coords[0] == lastX && coords[1] == lastY) {
      return Offset(coords[0] * tileSize + puzzleBorderSize, coords[1] * tileSize + puzzleBorderSize);
    }

    // Animate from last position to current position using animTime
    final x = lerpDouble(lastX, coords[0], _animTime) ?? coords[0];
    final y = lerpDouble(lastY, coords[1], _animTime) ?? coords[1];

    return Offset(x * tileSize + puzzleBorderSize, y * tileSize + puzzleBorderSize);
  }

  void _moveRow(int newX) {
    _startTileMoveAnim();
    final y = _empty[1];
    if (newX < _empty[0]) {
      // Move tiles right
      for (var i = _empty[0]; i > newX; i--) {
        tiles[y * size + i] = tiles[y * size + i - 1];
      }
    } else {
      // Move tiles left
      for (var i = _empty[0]; i < newX; i++) {
        tiles[y * size + i] = tiles[y * size + i + 1];
      }
    }

    // Mark the new empty space
    _empty[0] = newX;
    tiles[y * size + newX] = 0;
  }

  void _moveColumn(int newY) {
    _startTileMoveAnim();
    final x = _empty[0];
    if (newY < _empty[1]) {
      // Move tiles down
      for (var i = _empty[1]; i > newY; i--) {
        tiles[i * size + x] = tiles[(i - 1) * size + x];
      }
    } else {
      // Move tiles up
      for (var i = _empty[1]; i < newY; i++) {
        tiles[i * size + x] = tiles[(i + 1) * size + x];
      }
    }

    // Mark the new empty space
    _empty[1] = newY;
    tiles[newY * size + x] = 0;
  }

  List<int> _getCoords(int number, [bool last = false]) {
    List<int> t = last && lastTiles.isNotEmpty ? lastTiles : tiles;
    for (var y = 0; y < size; ++y) {
      for (var x = 0; x < size; ++x) {
        if (t[y * size + x] == number) {
          return [x, y];
        }
      }
    }
    return [];
  }

  bool canMoveHorizontal(int number) {
    if (number <= 0 || number > size * size - 1) {
      return false;
    }

    final coords = _getCoords(number);
    return coords[1] == _empty[1];
  }

  bool canMoveVertical(int number) {
    if (number <= 0 || number > size * size - 1) {
      return false;
    }

    final coords = _getCoords(number);
    return coords[0] == _empty[0];
  }

  // Debug print to console
  void _debugOutput() {
    if (!debugEnabled) {
      return;
    }

    var line = "";
    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        if (tiles[i * size + j] != 0) {
          line += tiles[i * size + j].toString().padLeft(2) + " ";
        } else {
          line += "   ";
        }
      }
      debugPrint(line);
      line = "";
    }

    debugPrint(line);
  }

  void doRandomMove() {
    final xOrY = Random().nextInt(2);
    if (xOrY == 0) {
      // Fill array with empty x values
      final empty = [for (var j = 0; j < size - 1; j++) j < _empty[0] ? j : j + 1];
      final newEmpty = empty[Random().nextInt(size - 1)];
      // Move row starting from newEmpty value
      _moveRow(newEmpty);
    } else {
      // Fill array with empty y values
      final empty = [for (var j = 0; j < size - 1; j++) j < _empty[1] ? j : j + 1];
      final newEmpty = empty[Random().nextInt(size - 1)];
      // Move column starting from newEmpty value
      _moveColumn(newEmpty);
    }
  }
}
