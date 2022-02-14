import 'dart:math';

import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_puzzle/game_time.dart';
import 'package:flutter_puzzle/lerp_value.dart';
import 'package:flutter_puzzle/scene.dart';
import 'package:vector_math/vector_math.dart';

const colorsStartAtSec = 30;
const flickerStartsAtSec = 20;
const swirlStartAtSec = 10;
const rotateStartAtSec = 0.2;
const toBlackStartAtSec = 50;

class Particle {
  Vector3 position = Vector3.zero();
  Vector3 originalPosition = Vector3.zero();
  double originalDistance = 0.0;
  Vector3 targetPosition = Vector3.zero();
  Vector4 color = Vector4.zero();
  double size = 0.0;
}

double wrap(double x, double min, double max) {
  return x - (max - min) * (x / (max - min)).floor();
}

class ParticleSystem extends Scene {
  List<Particle> particles = [];
  double width = 0;
  double height = 0;

  final colorLerp = LerpValue(0);
  final zFlickerLerp = LerpValue(0);
  final rotateLerp = LerpValue(0);
  final swirlLerp = LerpValue(0);
  final goToBlack = LerpValue(1);

  ParticleSystem({int? count}) {
    if (count != null) {
      particles = List<Particle>.generate(count, (index) => Particle());
    }

    _init2dGrid();
  }

  @override
  void render(Canvas canvas, Size size) {
    final maxSide = max(size.width, size.height) * 1.3;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final factorX = maxSide / width;
    final factorY = maxSide / height;

    final timeSwing = sin(GameTime.instance.current * 0.3) * 0.0015;

    Paint paint = Paint();

    final brightness = (goToBlack.value * 255).toInt();
    paint.color = Color.fromRGBO(brightness, brightness, brightness, 1);
    canvas.drawPaint(paint);

    for (var p in particles) {
      final angle = swirlLerp.value * timeSwing * p.originalDistance;

      final rot = Quaternion.euler(0, 0, angle);
      final pos = rot.rotated(p.position);

      paint.color = Color.fromRGBO(
        (p.color.x * 255).toInt(),
        (p.color.y * 255).toInt(),
        (p.color.z * 255).toInt(),
        (p.position.z + 1) * 0.75,
      );

      double x = pos.x * factorX + centerX;
      double y = pos.y * factorY + centerY;
      double offset = (0.55 * factorX) / (pos.z * 0.8 + 1.1);
      double radius = p.size * offset;

      // canvas.save();
      // canvas.rotate(angle * 0.3);
      canvas.drawCircle(Offset(x, y), radius, paint);
      // canvas.restore();
    }
  }

  void _init2dGrid() {
    const widthHalf = 800.0;
    const heightHalf = 800.0;

    const dx = 60.0;
    const dy = 60.0;

    for (double x = -widthHalf; x < widthHalf; x += dx) {
      for (double y = -heightHalf; y < heightHalf + dy; y += dy) {
        final particle = Particle();
        particle.position.x = x;
        particle.position.y = y;
        particle.targetPosition.x = x;
        particle.targetPosition.y = y;
        particle.originalPosition.x = x;
        particle.originalPosition.y = y;
        particle.originalDistance = particle.position.distanceTo(Vector3.zero());

        particle.size = 50.0;

        particles.add(particle);
      }
    }

    width = 2 * widthHalf;
    height = 2 * heightHalf;
  }

  @override
  void tick() {
    final time = GameTime.instance.stateTime;
    final cosine = cos(time);
    final sine = sin(time);
    for (var particle in particles) {
      particle.position.x = particle.originalPosition.x + (0.2 + rotateLerp.value) * cosine * 30;
      particle.position.y = particle.originalPosition.y + (0.2 + rotateLerp.value) * sine * 100;
      particle.position.z = zFlickerLerp.value * 0.3 * sin(5 * time + particle.position.x * 0.3 + particle.position.y * 0.1);
      Vector4 color = Vector4.zero();

      // Lerp between red and hsl shift
      Colors.hslToRgb(Vector4(sine * particle.originalDistance / 900, 1.0, 0.5, 1.0), color);
      particle.color.x = (1 - colorLerp.value) + (colorLerp.value) * color.x;
      particle.color.y = (1 - colorLerp.value) * 50 / 255 + (colorLerp.value) * color.y;
      particle.color.z = (1 - colorLerp.value) * 50 / 255 + (colorLerp.value) * color.z;
      particle.color.w = 1;
    }

    if (time < colorsStartAtSec) {
      colorLerp.set(0);
    } else {
      colorLerp.lerpTo(1, 4);
      colorLerp.tick(GameTime.instance.dt);
    }

    if (time < flickerStartsAtSec) {
      zFlickerLerp.set(0);
    } else {
      zFlickerLerp.lerpTo(1, 20);
      zFlickerLerp.tick(GameTime.instance.dt);
    }

    if (time < rotateStartAtSec) {
      rotateLerp.set(0);
    } else {
      rotateLerp.lerpTo(0.8, 10);
      rotateLerp.tick(GameTime.instance.dt);
    }

    if (time < swirlStartAtSec) {
      swirlLerp.set(0);
    } else {
      swirlLerp.lerpTo(1, 14);
      swirlLerp.tick(GameTime.instance.dt);
    }

    if (time < toBlackStartAtSec) {
      goToBlack.set(1);
    } else {
      goToBlack.lerpTo(0, 0.5);
      goToBlack.tick(GameTime.instance.dt);
    }
  }
}
