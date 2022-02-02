import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:flutter/material.dart' hide Colors;

class Particle {
  Vector3 position = Vector3.zero();
  Vector3 originalPosition = Vector3.zero();
  Vector3 targetPosition = Vector3.zero();
  Vector4 color = Vector4.zero();
  double size = 0.0;

  draw2d(Canvas canvas, Size psSize, Size canvasSize, double time, Matrix3 transform) {
    Paint paint = Paint()
      ..color = Color.fromRGBO(
        (color.x * 255).toInt(),
        (color.y * 255).toInt(),
        (color.z * 255).toInt(),
        (position.z + 1) / 2,
      )
      ..strokeWidth = size;
    // canvas.drawCircle(Offset(position.x, position.y), size, paint);

    final maxSide = max(canvasSize.width, canvasSize.height) * 1.3;

    final distance = position.distanceTo(Vector3.zero());
    final rot = Matrix3.rotationZ(time * distance * 0.00001);
    final pos = transform.transformed(rot.transformed(position));

    double x = (pos.x * maxSide) / psSize.width + (canvasSize.width / 2);
    double y = (pos.y * maxSide) / psSize.height + (canvasSize.height / 2);
    double offset = 1 / (pos.z * 0.8 + 1.1);
    double radius = size * 0.55 * offset * maxSide / psSize.width;
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
}

class ParticleSystem {
  List<Particle> particles = [];
  double width = 0;
  double height = 0;
  double currentTime = 0.0;

  ParticleSystem({int? count}) {
    if (count != null) {
      particles = List<Particle>.generate(count, (index) => Particle());
    }
  }

  void draw2d(Canvas canvas, Size size) {
    final rot = Matrix3.rotationZ(currentTime * 0.05);

    for (var particle in particles) {
      particle.draw2d(canvas, Size(width, height), size, currentTime, rot);
    }
  }

  void init2dGrid() {
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
        particle.color = Colors.red;
        particle.size = 50.0;

        particles.add(particle);
      }
    }

    width = 2 * widthHalf;
    height = 2 * heightHalf;
  }

  void tick(double time) {
    currentTime = time;
    for (var particle in particles) {
      double distance = particle.position.distanceTo(Vector3.zero());

      particle.position.z = 0.3 * sin(5 * time + particle.position.x * 0.3 + particle.position.y * 0.1);
      particle.position.x = particle.originalPosition.x + cos(time) * 30;
      particle.position.y = particle.originalPosition.y + sin(time) * 100;
    }
  }
}
