import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/lerp_value.dart';
import 'package:flutter_puzzle/scene.dart';

import 'game_time.dart';

const _numSections = 8;
const lerpTime = 1.0;

const switchFirst = 4;
const switchSecond = 8;
const switchThird = 12;

class Rays extends Scene {
  LerpValue ray2Angle = LerpValue(pi / 8);
  LerpValue ray4Angle = LerpValue(pi / 8);
  LerpValue ray8Angle = LerpValue(pi / 8);
  double angle = 0;
  double radius = 0;
  double time = 0;
  final color = LerpValue(1);

  @override
  void tick() {
    time += GameTime.instance.dt;
    angle = time * 0.4;
    radius += GameTime.instance.dt * 1200;

    color.lerpTo(1, 2);
    color.tick(GameTime.instance.dt);

    if (time < switchFirst) {
      ray2Angle.set(pi / 8);
      ray4Angle.set(pi / 8);
      ray8Angle.set(pi / 8);
    } else if (time < switchSecond) {
      ray2Angle.lerpTo(pi / 4, lerpTime);
      ray4Angle.lerpTo(pi / 4, lerpTime);
      ray8Angle.lerpTo(0);
    } else if (time < switchThird) {
      ray2Angle.lerpTo(pi / 2, lerpTime);
      ray4Angle.lerpTo(0, lerpTime);
    } else {
      ray2Angle.lerpTo(0, lerpTime);

      if (ray2Angle.value == 0) {
        state = SceneState.done;
      } else {
        state = SceneState.fadeOut;
      }
    }

    ray2Angle.tick(GameTime.instance.dt);
    ray4Angle.tick(GameTime.instance.dt);
    ray8Angle.tick(GameTime.instance.dt);
  }

  @override
  void render(Canvas canvas, Size size) {
    Paint paint = Paint();

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxSize = max(size.width, size.height);
    if (radius > maxSize && state == SceneState.running) {
      radius = 0;
    }

    final circleColor = Color.lerp(const Color(0x00ffffff), Colors.red.shade100, color.value)!;
    paint.color = Color.lerp(circleColor, const Color.fromARGB(0, 255, 255, 255), radius / maxSize)!;
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    const sectionDelta = 2 * pi / _numSections;
    paint.color = Color.lerp(const Color(0x00ffffff), Colors.red, color.value)!;
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

  @override
  void reset() {
    state = SceneState.running;
    time = 0;
    color.set(0);
  }

  @override
  void gameOver() {
    super.gameOver();
    color.set(1);
  }
}
