import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/config.dart';
import 'package:flutter_puzzle/puzzle.dart';
import 'package:flutter_puzzle/scene.dart';

import 'game_time.dart';

class StartScreen extends Scene {
  final Puzzle _puzzle2 = Puzzle(2, 0);
  final Puzzle _puzzle3 = Puzzle(3, 0);
  final Puzzle _puzzle4 = Puzzle(4, 0);
  final Puzzle _puzzle5 = Puzzle(5, 0);
  double lastRandom2 = 0;
  double lastRandom3 = 0.33;
  double lastRandom4 = 0.66;

  List<TextPainter> textPainters = [];

  // ATTENTION: Has to be done every frame for some reason.
  void cacheTextPainters() {
    textPainters.clear();
    // Cache the text painters because TextPainter.layout() is slow.
    for (int i = 0; i < 26; ++i) {
      TextSpan ts = TextSpan(
        style: TextStyle(
          fontSize: tileSize / 2,
          fontWeight: FontWeight.bold,
          fontFamily: "Rowdies",
          color: Colors.blue.shade800,
        ),
        text: "$i",
      );

      TextPainter tp = TextPainter(text: ts, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      tp.layout();
      textPainters.add(tp);
    }
  }

  @override
  void tick() {
    if (GameTime.instance.current > lastRandom2) {
      _puzzle2.doRandomMove();
      _puzzle5.doRandomMove();
      while (GameTime.instance.current > lastRandom2) {
        lastRandom2++;
      }
    }

    if (GameTime.instance.current > lastRandom3) {
      _puzzle3.doRandomMove();
      while (GameTime.instance.current > lastRandom3) {
        lastRandom3++;
      }
    }
    if (GameTime.instance.current > lastRandom4) {
      _puzzle4.doRandomMove();
      while (GameTime.instance.current > lastRandom4) {
        lastRandom4++;
      }
    }

    final dt = GameTime.instance.dt;

    _puzzle2.tickTileMoveAnim(dt);
    _puzzle3.tickTileMoveAnim(dt);
    _puzzle4.tickTileMoveAnim(dt);
    _puzzle5.tickTileMoveAnim(dt);
  }

  void paintPuzzle(Puzzle puzzle, Canvas canvas) {
    Paint paint = Paint();
    paint.color = Colors.blue;
    final sizeHalf = puzzle.screenSize / 2;
    canvas.drawRRect(
      RRect.fromLTRBR(
        -sizeHalf,
        -sizeHalf,
        sizeHalf,
        sizeHalf,
        const Radius.circular(tileSize / 5),
      ),
      paint,
    );

    for (int i = 1; i < puzzle.size * puzzle.size; ++i) {
      final offset = puzzle.getTileOffset(i);
      final left = offset.dx - sizeHalf;
      final top = offset.dy - sizeHalf;
      final right = left + tileSize;
      final bottom = top + tileSize;

      paint.color = Colors.white;
      canvas.drawRRect(
        RRect.fromLTRBR(
          left + tileBorderSize,
          top + tileBorderSize,
          right - tileBorderSize,
          bottom - tileBorderSize,
          const Radius.circular(tileSize / 5),
        ),
        paint,
      );

      TextPainter tp = textPainters[i];
      tp.paint(canvas, Offset(left + (tileSize - tp.width) / 2, top + (tileSize - tp.height) / 2));
    }
  }

  void paintPuzzleRing(Canvas canvas, Size size, Puzzle puzzle, int count, double radius, double frequency) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final d = 2 * pi / count;
    for (var i = 0; i < count; i++) {
      final angle = GameTime.instance.current * frequency + i * d;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2);
      paintPuzzle(puzzle, canvas);
      canvas.restore();
    }
  }

  void paintRays(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.red;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxSize = max(size.width, size.height);

    const numSections = 10;
    const sectionDelta = 2 * pi / numSections;

    for (int i = 0; i < numSections; i++) {
      final angle = GameTime.instance.current * 0.2 + i * sectionDelta;
      final x = cx + maxSize * sin(angle);
      final y = cy + maxSize * cos(angle);

      final x2 = cx + maxSize * sin(angle + sectionDelta / 2);
      final y2 = cy + maxSize * cos(angle + sectionDelta / 2);

      var path = Path();
      path.moveTo(cx, cy);
      path.lineTo(x, y);
      path.lineTo(x2, y2);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  void render(Canvas canvas, Size size) {
    cacheTextPainters();

    paintRays(canvas, size);

    const num2 = 6;
    final r2 = _puzzle2.screenSize * 1.2;
    const f2 = 0.3;

    const num3 = 10;
    final r3 = r2 + _puzzle3.screenSize * 1;
    const f3 = 0.2;

    const num4 = 13;
    final r4 = r3 + _puzzle4.screenSize * 1;
    const f4 = 0.1;

    const num5 = 15;
    final r5 = r4 + _puzzle5.screenSize * 1;
    const f5 = 0.1;

    paintPuzzleRing(canvas, size, _puzzle2, num2, r2, f2);
    paintPuzzleRing(canvas, size, _puzzle3, num3, r3, f3);

    final maxSize = max(size.width, size.height);
    if (maxSize > r4 + _puzzle4.screenSize) {
      paintPuzzleRing(canvas, size, _puzzle4, num4, r4, f4);
    }

    if (maxSize > r5 + _puzzle5.screenSize) {
      paintPuzzleRing(canvas, size, _puzzle5, num5, r5, f5);
    }

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), Paint()..color = Colors.white.withOpacity(0.4));
  }

  @override
  void reset() {
    // pass
  }
}
