// create a stateless widget
import 'package:flutter/material.dart';
import 'package:flutter_puzzle/puzzle.dart';

import 'config.dart';

class Tile extends StatelessWidget {
  final int number;
  final Function(int number) onTap;
  final bool canMoveHorizontal;
  final bool canMoveVertical;

  const Tile(this.number, this.onTap, this.canMoveHorizontal, this.canMoveVertical, {Key? key}) : super(key: key);

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
            borderRadius: BorderRadius.circular(tileSize / 5)),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: tileSize / 2,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
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

  @override
  Widget build(BuildContext context) {
    List<AnimatedPositioned> tiles = [];
    for (int i = 0; i < _puzzle.tiles.length; i++) {
      final tile = _puzzle.tiles[i];
      final row = i ~/ _puzzle.size;
      final col = i % _puzzle.size;
      if (tile != 0) {
        tiles.add(AnimatedPositioned(
          key: ValueKey(tile),
          left: col * tileSize,
          top: row * tileSize,
          duration: const Duration(milliseconds: slideTimeMs),
          child: Tile(tile, onTap, _puzzle.canMoveHorizontal(tile), _puzzle.canMoveVertical(tile)),
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
