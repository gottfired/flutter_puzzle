import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_puzzle/game.dart';

class GameOverPainter extends CustomPainter {
  final double value;

  GameOverPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // below one is big circle and instead of this circle you can draw your shape here.
    final paint = Paint()
      ..color = Colors.blue.shade600
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addOval(Rect.fromCircle(center: center, radius: max(0, 1 - value) * max(size.width, size.height)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class GameOver extends StatefulWidget {
  final Function() onGameOverFinished;
  const GameOver(this.onGameOverFinished, {Key? key}) : super(key: key);

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  late final Ticker ticker;
  double time = 0;
  double dt = 0;
  double delta = 0;

  _GameOverState() {
    ticker = Ticker((duration) {
      final current = duration.inMilliseconds / 1000.0;
      setState(() {
        dt = current - time;
        time = current;

        delta = (DateTime.now().millisecondsSinceEpoch - Game.instance.gameOverTime) / 1000;
        if (delta > 1.1) {
          ticker.stop();
          widget.onGameOverFinished();
        }
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
      painter: GameOverPainter(value: delta),
    );
  }
}
