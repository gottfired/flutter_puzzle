// create a stateless widget
import 'package:flutter/material.dart';
import 'package:flutter_puzzle/puzzle.dart';

import 'config.dart';

class Tile extends StatelessWidget {
  final int number;
  final Function(int number) onTap;
  final bool canMoveHorizontal;
  final bool canMoveVertical;
  final bool red;

  const Tile(this.number, this.onTap, this.canMoveHorizontal, this.canMoveVertical, this.red, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        onTap(number);
      },
      onVerticalDragStart: (details) {
        if (canMoveVertical) {
          onTap(number);
        }
      },
      onHorizontalDragStart: (details) {
        if (canMoveHorizontal) {
          onTap(number);
        }
      },
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
            width: tileBorderSize,
          ),
          borderRadius: BorderRadius.circular(tileSize / 5),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: tileSize / 2,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ),
    );
  }
}

class Grid extends StatelessWidget {
  final Puzzle _puzzle;
  final Function(int number) onTap;

  const Grid(this._puzzle, this.onTap, {Key? key}) : super(key: key);

  bool _isRed(int number) {
    if (_puzzle.size == 2) {
      return number == 1;
    } else if (_puzzle.size == 3) {
      return number % 2 == 1;
    } else {
      return [1, 3, 6, 8, 9, 11, 14].contains(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AnimatedPositioned> tiles = [];
    for (int i = 0; i < _puzzle.tiles.length; i++) {
      final number = _puzzle.tiles[i];
      final row = i ~/ _puzzle.size;
      final col = i % _puzzle.size;
      if (number != 0) {
        tiles.add(AnimatedPositioned(
          key: ValueKey(number),
          left: col * tileSize,
          top: row * tileSize,
          duration: const Duration(milliseconds: slideTimeMs),
          child: Tile(
            number,
            onTap,
            _puzzle.canMoveHorizontal(number),
            _puzzle.canMoveVertical(number),
            _isRed(number),
          ),
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: puzzleBorderSize,
        ),
        borderRadius: BorderRadius.circular(tileSize / 5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade400.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(color: Colors.blue, width: tileSize * _puzzle.size, height: tileSize * _puzzle.size),
          ...tiles,
        ],
      ),
    );
  }
}
