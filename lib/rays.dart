import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/lerp_value.dart';
import 'package:flutter_puzzle/scene.dart';

import 'game_time.dart';

const _numSections = 8;
const lerpTime = 4.0;

const switchTo4At = lerpTime;
const switchTo8At = lerpTime * 2;

class Rays extends Scene {
  LerpValue ray2Angle = LerpValue(pi / 2);
  LerpValue ray4Angle = LerpValue(0);
  LerpValue ray8Angle = LerpValue(0);
  double angle = 0;
  int color = 0;
  double radius = 0;

  final colors = [
    Colors.white,
    Colors.red.shade50,
  ];

  @override
  void tick() {
    final time = GameTime.instance.stateTime;
    angle = time * 0.4;
    radius += GameTime.instance.dt * 1000;

    if (time < 0.2) {
      ray2Angle.set(0);
      ray4Angle.set(0);
      ray8Angle.set(0);
    } else if (time < switchTo4At) {
      ray2Angle.lerpTo(pi / 2, lerpTime);
      ray2Angle.tick(GameTime.instance.dt);
    } else if (time < switchTo8At) {
      ray2Angle.lerpTo(pi / 4, lerpTime);
      ray2Angle.tick(GameTime.instance.dt);

      ray4Angle.lerpTo(pi / 4, lerpTime);
      ray4Angle.tick(GameTime.instance.dt);
    } else {
      ray2Angle.lerpTo(pi / 8, lerpTime);
      ray2Angle.tick(GameTime.instance.dt);

      ray4Angle.lerpTo(pi / 8, lerpTime);
      ray4Angle.tick(GameTime.instance.dt);

      ray8Angle.lerpTo(pi / 8, lerpTime);
      ray8Angle.tick(GameTime.instance.dt);
    }
  }

  @override
  void render(Canvas canvas, Size size) {
    Paint paint = Paint();

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxSize = max(size.width, size.height);

    int previousColor = color - 1;
    if (previousColor < 0) {
      previousColor = colors.length - 1;
    }

    paint.color = colors[previousColor];
    canvas.drawPaint(paint);

    paint.color = colors[color];
    canvas.drawCircle(Offset(cx, cy), radius, paint);
    if (radius > maxSize) {
      color = (color + 1) % colors.length;
      radius = 0;
    }

    const sectionDelta = 2 * pi / _numSections;
    paint.color = Colors.red;
    for (int i = 0; i < _numSections; i++) {
      final angle = this.angle + i * sectionDelta;
      double width = 0;
      if (i == 0 || i == 4) {
        width = ray2Angle.value / 2;
      } else if (i == 2 || i == 6) {
        width = ray4Angle.value / 2;
      } else if (i == 1 || i == 3 || i == 5 || i == 7) {
        width = ray8Angle.value / 2;
      }

      if (width > 0) {
        final x = cx + maxSize * sin(angle - width);
        final y = cy + maxSize * cos(angle - width);

        final x2 = cx + maxSize * sin(angle + width);
        final y2 = cy + maxSize * cos(angle + width);

        var path = Path();
        path.moveTo(cx, cy);
        path.lineTo(x, y);
        path.lineTo(x2, y2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
}
