// create a stateless widget
import 'package:flutter/material.dart';
import 'package:flutter_puzzle/puzzle.dart';

const tileSize = 60.0;

class Tile extends StatelessWidget {
  final int number;

  const Tile(this.number, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
            width: 1,
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
    );
  }
}

class Grid extends StatelessWidget {
  final Puzzle _puzzle;

  const Grid(this._puzzle, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Positioned> tiles = [];
    for (int i = 0; i < _puzzle.tiles.length; i++) {
      final tile = _puzzle.tiles[i];
      final row = i ~/ _puzzle.size;
      final col = i % _puzzle.size;
      if (tile != 0) {
        tiles.add(Positioned(
          left: col * tileSize,
          top: row * tileSize,
          child: Tile(tile, key: ValueKey(tile)),
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 4,
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
