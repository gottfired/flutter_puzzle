// create a stateless widget
import 'package:flutter/material.dart';
import 'package:pushtrix/puzzle.dart';

import 'config.dart';
import 'tile.dart';

class Grid extends StatelessWidget {
  final Puzzle _puzzle;
  final Function(int number)? onTap;

  final bool? withShadow;

  const Grid(this._puzzle, {Key? key, this.onTap, this.withShadow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<AnimatedPositioned> tiles = [];
    for (int i = 0; i < _puzzle.tiles.length; i++) {
      final number = _puzzle.tiles[i];
      final row = i ~/ _puzzle.size;
      final col = i % _puzzle.size;
      if (number != 0) {
        tiles.add(
          AnimatedPositioned(
            key: ValueKey(number),
            left: col * tileSize,
            top: row * tileSize,
            duration: const Duration(milliseconds: slideTimeMs),
            child: Tile(
              number,
              onTap,
              _puzzle.canMoveHorizontal(number),
              _puzzle.canMoveVertical(number),
            ),
          ),
        );
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
          if (withShadow != false)
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
