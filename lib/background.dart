import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_puzzle/game.dart';
import 'package:flutter_puzzle/particle.dart';

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
        ..color = Colors.blue.shade50
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

  ParticleSystem particles = ParticleSystem();

  _BackgroundState() {
    ticker = Ticker((duration) {
      final current = duration.inMilliseconds / 1000.0;
      // Only animate with half frame rate
      if (frame & 1 == 0) {
        particles.tick(current);
      }

      setState(() {
        dt = current - time;
        time = current;
        frame++;
      });
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
      painter: BackgroundPainter(value: time, particles: particles),
    );
  }
}
