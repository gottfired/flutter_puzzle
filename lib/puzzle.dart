import 'dart:math';

import 'package:flutter/foundation.dart';

const shuffleCount = 20;

class Puzzle {
  final List<int> tiles = [];
  final List<int> _empty;
  final int size;

  Puzzle(this.size) : _empty = [size - 1, size - 1] {
    for (int i = 0; i < size * size - 1; i++) {
      tiles.add(i + 1);
    }

    // Empty is marked with 0
    tiles.add(0);

    shuffle();
    debugOutput();
  }

  void shuffle() {
    for (var i = 0; i < shuffleCount; ++i) {
      final xOrY = Random().nextInt(2);
      if (xOrY == 0) {
        final empty = [for (var j = 0; j < size - 1; j++) j < _empty[0] ? j : j + 1];
        final newEmpty = empty[Random().nextInt(size - 1)];
        _moveRow(newEmpty);
      } else {
        final empty = [for (var j = 0; j < size - 1; j++) j < _empty[1] ? j : j + 1];
        final newEmpty = empty[Random().nextInt(size - 1)];
        _moveColumn(newEmpty);
      }
    }
  }

  void move(int number) {
    if (number <= 0 || number > size * size - 1) {
      return;
    }

    // find coords of number
    final coords = getCoords(number);
    final x = coords[0];
    final y = coords[1];

    if (x == _empty[0]) {
      _moveColumn(y);
      debugOutput();
    } else if (y == _empty[1]) {
      _moveRow(x);
      debugOutput();
    }
  }

  void _moveRow(int newX) {
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

  List<int> getCoords(int number) {
    for (var y = 0; y < size; ++y) {
      for (var x = 0; x < size; ++x) {
        if (tiles[y * size + x] == number) {
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

    final coords = getCoords(number);
    return coords[1] == _empty[1];
  }

  bool canMoveVertical(int number) {
    if (number <= 0 || number > size * size - 1) {
      return false;
    }

    final coords = getCoords(number);
    return coords[0] == _empty[0];
  }

  // Debug print to console
  void debugOutput() {
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
}
