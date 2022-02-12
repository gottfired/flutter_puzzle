import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'package:flutter/material.dart' hide Colors;

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
    final maxSide = max(size.width, size.height) * 1.3;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final factorX = maxSide / width;
    final factorY = maxSide / height;

    final timeSwing = sin(currentTime * 0.3) * 0.0015;

    Paint paint = Paint();

    // paint.color = Color(0xff000000);
    // canvas.drawPaint(paint);

    for (var p in particles) {
      final angle = timeSwing * p.originalDistance;

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
        particle.originalDistance = particle.position.distanceTo(Vector3.zero());
        // Colors.fromRgba(30, 136, 229, 255, particle.color); // blue
        // Colors.fromRgba(255, 87, 34, 255, particle.color); // orange
        // Colors.hslToRgb(Vector4(particle.originalDistance / 1000, 1.0, 0.5, 1.0), particle.color);

        // Colors.fromRgba(255, 50, 50, 255, particle.color);

        particle.size = 50.0;

        particles.add(particle);
      }
    }

    width = 2 * widthHalf;
    height = 2 * heightHalf;
  }

  void tick(double time) {
    currentTime = time;
    final cosine = cos(time);
    final sine = sin(time);
    for (var particle in particles) {
      particle.position.x = particle.originalPosition.x + cosine * 30;
      particle.position.y = particle.originalPosition.y + sine * 100;
      particle.position.z = 0.3 * sin(5 * time + particle.position.x * 0.3 + particle.position.y * 0.1);
      Colors.hslToRgb(Vector4(sine * particle.originalDistance / 900, 1.0, 0.5, 1.0), particle.color);
      // continue here -> start with original color -> interpolate to color shift
      // start with white -> interpolate to black
    }
  }
}
