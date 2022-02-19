import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/game_time.dart';
import 'package:flutter_puzzle/scene.dart';
import 'package:vector_math/vector_math_64.dart';

class Cubes extends Scene {
  final cube = [
    // Back face
    Vector4(1, 1, -1, 1),
    Vector4(1, -1, -1, 1),
    Vector4(-1, -1, -1, 1),
    Vector4(-1, 1, -1, 1),

    // Front face
    Vector4(1, 1, 1, 1),
    Vector4(1, -1, 1, 1),
    Vector4(-1, -1, 1, 1),
    Vector4(-1, 1, 1, 1),
  ];

  final cubeEdges = [
    // back
    Vector2(0, 1),
    Vector2(1, 2),
    Vector2(2, 3),
    Vector2(3, 0),
    // front
    Vector2(4, 5),
    Vector2(5, 6),
    Vector2(6, 7),
    Vector2(7, 4),
    // sides
    Vector2(0, 4),
    Vector2(1, 5),
    Vector2(2, 6),
    Vector2(3, 7),
  ];

  @override
  void render(Canvas canvas, Size size) {
    final time = GameTime.instance.stateTime;
    final rz = Matrix4.rotationZ(time * 1);
    final ry = Matrix4.rotationY(time * 0.0);
    final rx = Matrix4.rotationX(time * 4);

    final view = makeViewMatrix(Vector3(0, 0, (sin(time * 2) + 1) * 3 + 2.0), Vector3(0, 0, 0), Vector3(cos(time), sin(time), 0));
    final projection = makePerspectiveMatrix(pi / 3, size.width / size.height, 0.1, 100);
    final vp = projection * view;

    // calculate center
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = const Color(0xFFff0000)
      ..strokeWidth = 4.0;

    final num = 5;
    for (var i = 0; i < num; i++) {
      for (var j = 0; j < num; j++) {
        final dist = 3.5;
        final translation = Matrix4.translation(Vector3((i - num ~/ 2) * dist, (j - num ~/ 2) * dist, -8));

        final mvp = vp * translation * rz * ry * rx;
        List<Vector4> out = [];
        for (final v in cube) {
          out.add(mvp.transformed(v));
        }

        for (final edge in cubeEdges) {
          final v1 = out[edge.x.toInt()];
          final v2 = out[edge.y.toInt()];

          canvas.drawLine(
            Offset(v1.x * cx / v1.w + cx, v1.y * cy / v1.w + cy),
            Offset(v2.x * cx / v2.w + cx, v2.y * cy / v2.w + cy),
            paint,
          );
        }
      }
    }
  }

  @override
  void reset() {
    // TODO: implement reset
  }

  @override
  void tick() {
    // TODO: implement tick
  }
}
