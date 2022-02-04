import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_puzzle/game.dart';

enum TransitionState {
  stateChange,
  finished,
}

class TransitionPainter extends CustomPainter {
  final double value;
  final bool closed;

  TransitionPainter({required this.value, required this.closed});

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
    final radius = !closed ? max(0, 1 - value) : value - 1;
    path.addOval(Rect.fromCircle(center: center, radius: radius * max(size.width, size.height)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class StateTransition extends StatefulWidget {
  final Function(TransitionState state) onTransition;
  const StateTransition(this.onTransition, {Key? key}) : super(key: key);

  @override
  State<StateTransition> createState() => _StateTransitionState();
}

class _StateTransitionState extends State<StateTransition> {
  late final Ticker ticker;
  double time = 0;
  double dt = 0;
  double value = 0;
  bool _isClosed = false;

  _StateTransitionState() {
    ticker = Ticker((duration) {
      final current = duration.inMilliseconds / 1000.0;
      setState(() {
        dt = current - time;
        time = current;

        // Calculate seconds passed since the start of the animation.
        value = (DateTime.now().millisecondsSinceEpoch - (Game.instance.transitionStarted ?? 0)) / 1000;
        if (value > 1 && !_isClosed) {
          _isClosed = true;
          widget.onTransition(TransitionState.stateChange);
        }

        if (value > 2) {
          debugPrint("transition finished");
          ticker.stop();
          Game.instance.transitionStarted = null;
          widget.onTransition(TransitionState.finished);
        }
      });
    });

    ticker.start();
  }

  @override
  void dispose() {
    debugPrint("_StateTransitionState dispose");
    super.dispose();
    ticker.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CustomPaint(
      size: size,
      painter: TransitionPainter(value: value, closed: _isClosed),
    );
  }
}
