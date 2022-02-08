import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_puzzle/game.dart';
import 'package:flutter_puzzle/particle.dart';
import 'package:flutter_puzzle/puzzle.dart';

import 'config.dart';

class BackgroundPainter extends CustomPainter {
  final double value;
  ParticleSystem? particles;
  _BackgroundState state;

  List<TextPainter> textPainters = [];

  BackgroundPainter({required this.value, required this.state, this.particles}) {
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

/*
  void dummyPaint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final length = min(size.width, size.height);

    // Paint line moving up/down
    final range = size.height / 3;
    final y = size.height / 2 + sin(value) * range;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Paint center pulsing circle
    paint = Paint()
      ..color = Colors.blue.shade50
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final rMin = length * 0.4;
    final rMax = length * 0.45;
    canvas.drawCircle(Offset(center.dx, center.dy), rMin + (rMax - rMin) * sin(4 * value), paint);

    // Paint rotating circles
    paint = Paint()..color = Colors.blue.shade100;

    final r2 = length / 2;
    canvas.drawCircle(Offset(center.dx + r2 * cos(2 * value), center.dy + r2 * sin(2 * value)), 50, paint);

    paint = Paint()..color = Colors.blue.shade200;

    final r3 = length / 3;
    canvas.drawCircle(Offset(center.dx + r3 * cos(2 * value), center.dy + r3 * sin(2 * value)), 20, paint);
  }

  void paintPulsingCenter(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final length = min(size.width, size.height);

    paint = Paint()
      ..color = Colors.blue.shade50
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final rMin = length * 0.3;
    final rMax = length * 0.35;
    canvas.drawCircle(Offset(center.dx, center.dy), rMin + (rMax - rMin) * sin(4 * value), paint);
  }
  */

  void paintParticles(Canvas canvas, Size size) {
    if (particles == null) {
      return;
    }

    particles!.draw2d(canvas, size);
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
      final angle = value * frequency + i * d;
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
      final angle = value * 0.2 + i * sectionDelta;
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

  void paintStartScreen(Canvas canvas, Size size) {
    paintRays(canvas, size);

    const num2 = 6;
    final r2 = state._puzzle2.screenSize * 1.2;
    const f2 = 0.3;

    const num3 = 10;
    final r3 = r2 + state._puzzle3.screenSize * 1;
    const f3 = 0.2;

    const num4 = 13;
    final r4 = r3 + state._puzzle4.screenSize * 1;
    const f4 = 0.1;

    const num5 = 15;
    final r5 = r4 + state._puzzle5.screenSize * 1;
    const f5 = 0.1;

    paintPuzzleRing(canvas, size, state._puzzle2, num2, r2, f2);
    paintPuzzleRing(canvas, size, state._puzzle3, num3, r3, f3);

    final maxSize = max(size.width, size.height);
    if (maxSize > r4 + state._puzzle4.screenSize) {
      paintPuzzleRing(canvas, size, state._puzzle4, num4, r4, f4);
    }

    if (maxSize > r5 + state._puzzle5.screenSize) {
      paintPuzzleRing(canvas, size, state._puzzle5, num5, r5, f5);
    }

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), Paint()..color = Colors.white.withOpacity(0.4));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (Game.instance.state == GameState.startScreen) {
      paintStartScreen(canvas, size);
      return;
    }

    paintParticles(canvas, size);
    // paintPulsingCenter(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  late final Ticker ticker;
  double time = 0;
  double dt = 0;
  int frame = 0;
  final Puzzle _puzzle2 = Puzzle(2, 0);
  final Puzzle _puzzle3 = Puzzle(3, 0);
  final Puzzle _puzzle4 = Puzzle(4, 0);
  final Puzzle _puzzle5 = Puzzle(5, 0);
  double lastRandom2 = 0;
  double lastRandom3 = 0.33;
  double lastRandom4 = 0.66;

  ParticleSystem particles = ParticleSystem();

  _BackgroundState() {
    ticker = Ticker((duration) {
      final current = duration.inMilliseconds / 1000.0;
      frame++;
      if (frame & 1 == 0) {
        particles.tick(current);
      }

      if (time > lastRandom2) {
        _puzzle2.doRandomMove();
        _puzzle5.doRandomMove();
        lastRandom2++;
      }

      if (time > lastRandom3) {
        _puzzle3.doRandomMove();
        lastRandom3++;
      }
      if (time > lastRandom4) {
        _puzzle4.doRandomMove();
        lastRandom4++;
      }

      if (frame & 1 == 0) {
        setState(() {
          dt = current - time;
          time = current;

          _puzzle2.tickTileMoveAnim(dt);
          _puzzle3.tickTileMoveAnim(dt);
          _puzzle4.tickTileMoveAnim(dt);
          _puzzle5.tickTileMoveAnim(dt);
        });
      }
    });

    particles.init2dGrid();

    ticker.start();
  }

  @override
  void dispose() {
    super.dispose();
    ticker.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CustomPaint(
      size: size,
      painter: BackgroundPainter(value: time, state: this, particles: particles),
    );
  }
}
