import 'package:flutter/material.dart';

import 'audio.dart';
import 'config.dart';

class Tile extends StatelessWidget {
  final int number;
  final Function(int number)? onTap;
  final bool canMoveHorizontal;
  final bool canMoveVertical;
  final bool? red;

  const Tile(this.number, this.onTap, this.canMoveHorizontal, this.canMoveVertical, {Key? key, this.red}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) {
        onTap?.call(number);
        Audio.instance.swish();
      },
      // onVerticalDragStart: (details) {
      //   if (canMoveVertical) {
      //     onTap?.call(number);
      //   }
      // },
      // onHorizontalDragStart: (details) {
      //   if (canMoveHorizontal) {
      //     onTap?.call(number);
      //   }
      // },
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
