// create a stateless widget
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
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
          Container(color: Colors.blue, width: tileSize * 3, height: tileSize * 3),
          const Positioned(
            left: 0,
            top: 0,
            child: Tile(1),
          ),
          const Positioned(
            left: tileSize,
            top: 0,
            child: Tile(2),
          ),
          const Positioned(
            left: 2 * tileSize,
            top: 0,
            child: Tile(3),
          ),
          const Positioned(
            left: 0,
            top: tileSize,
            child: Tile(4),
          ),
          const Positioned(
            left: tileSize,
            top: tileSize,
            child: Tile(5),
          ),
          const Positioned(
            left: 2 * tileSize,
            top: tileSize,
            child: Tile(6),
          ),
          const Positioned(
            left: 0,
            top: 2 * tileSize,
            child: Tile(7),
          ),
          const Positioned(
            left: tileSize,
            top: 2 * tileSize,
            child: Tile(8),
          ),
        ],
      ),
    );
  }
}
