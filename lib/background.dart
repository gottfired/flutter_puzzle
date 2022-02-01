import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_puzzle/game.dart';

class BackgroundPainter extends CustomPainter {
  final double value;

  BackgroundPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    if (Game.instance.state == GameState.startScreen) {
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final Path path = Path();
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, paint);
      return;
    }

    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final length = min(size.width, size.height);

    // Paint line moving up/down
    final range = size.width / 4;
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

  _BackgroundState() {
    ticker = Ticker((duration) {
      setState(() {
        final current = duration.inMilliseconds / 1000.0;
        dt = current - time;
        time = current;
      });
    });

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
      painter: BackgroundPainter(value: time),
    );
  }
}
