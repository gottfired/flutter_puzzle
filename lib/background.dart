import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_puzzle/game.dart';
import 'package:flutter_puzzle/grid.dart';
import 'package:flutter_puzzle/particle.dart';
import 'package:flutter_puzzle/puzzle.dart';

class BackgroundPainter extends CustomPainter {
  final double value;
  ParticleSystem? particles;

  BackgroundPainter({required this.value, this.particles});

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

  void paintParticles(Canvas canvas, Size size) {
    if (particles == null) {
      return;
    }

    particles!.draw2d(canvas, size);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (Game.instance.state == GameState.startScreen) {
      final paint = Paint()
        ..color = Colors.white10.withAlpha(180)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final Path path = Path();
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, paint);
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

  List<Positioned> _buildStartScreen(BuildContext context, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final maxAxis = max(size.width, size.height);

    final List<Positioned> p = [];

    const num2 = 5;
    final r2 = _puzzle2.screenSize * 1.2;
    const d2 = 2 * pi / num2;
    const f2 = 0.3;

    const num3 = 7;
    final r3 = r2 + _puzzle3.screenSize * 1.2;
    const d3 = 2 * pi / num3;
    const f3 = 0.2;

    const num4 = 9;
    final r4 = r3 + _puzzle4.screenSize * 1.2;
    const d4 = 2 * pi / num4;
    const f4 = 0.1;

    const num5 = 11;
    final r5 = r4 + _puzzle5.screenSize * 1;
    const d5 = 2 * pi / num5;
    const f5 = 0.1;

    // if (r5 + _puzzle5.screenSize < maxAxis) {
    //   for (var i = 0; i < num5; i++) {
    //     final x = cx + r5 * cos(time * f5 - i * d5) - _puzzle5.screenSize / 2;
    //     final y = cy + r5 * sin(time * f5 - i * d5) - _puzzle5.screenSize / 2;
    //     p.add(Positioned(left: x, top: y, child: Grid(_puzzle5, withShadow: false)));
    //   }
    // }

    if (r4 + _puzzle4.screenSize < maxAxis) {
      for (var i = 0; i < num4; i++) {
        final x = cx + r4 * cos(time * f4 - i * d4) - _puzzle4.screenSize / 2;
        final y = cy + r4 * sin(time * f4 - i * d4) - _puzzle4.screenSize / 2;
        p.add(Positioned(key: ValueKey("4_$i"), left: x, top: y, child: Grid(_puzzle4, withShadow: false)));
        // p.add(Positioned(
        //     left: x,
        //     top: y,
        //     child: Container(
        //       width: _puzzle4.screenSize,
        //       height: _puzzle4.screenSize,
        //       color: Colors.blue,
        //     )));
      }
    }

    if (r3 + _puzzle3.screenSize < maxAxis) {
      for (var i = 0; i < num3; i++) {
        final x = cx + r3 * cos(-(time * f3 - i * d3)) - _puzzle3.screenSize / 2;
        final y = cy + r3 * sin(-(time * f3 - i * d3)) - _puzzle3.screenSize / 2;
        p.add(Positioned(key: ValueKey("3_$i"), left: x, top: y, child: Grid(_puzzle3, withShadow: false)));
        // p.add(Positioned(
        //     left: x,
        //     top: y,
        //     child: Container(
        //       width: _puzzle3.screenSize,
        //       height: _puzzle3.screenSize,
        //       color: Colors.blue,
        //     )));
      }
    }

    for (var i = 0; i < num2; i++) {
      final x = cx + r2 * cos(time * f2 + i * d2) - _puzzle2.screenSize / 2;
      final y = cy + r2 * sin(time * f2 + i * d2) - _puzzle2.screenSize / 2;
      p.add(Positioned(key: ValueKey("2_$i"), left: x, top: y, child: Grid(_puzzle2, withShadow: false)));
      // p.add(Positioned(
      //     left: x,
      //     top: y,
      //     child: Container(
      //       width: _puzzle2.screenSize,
      //       height: _puzzle2.screenSize,
      //       color: Colors.blue,
      //     )));
    }

    return p;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(children: [
      ...(Game.instance.state == GameState.startScreen ? _buildStartScreen(context, size) : [const SizedBox()]),
      CustomPaint(
        size: size,
        painter: BackgroundPainter(value: time, particles: particles),
      )
    ]);
  }
}
