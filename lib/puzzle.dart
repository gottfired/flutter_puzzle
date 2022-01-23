import 'dart:math';

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
}
