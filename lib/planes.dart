import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/game_time.dart';
import 'package:flutter_puzzle/scene.dart';
import 'package:vector_math/vector_math_64.dart';

class Cubes extends Scene {
  final cube = [
    // Back face
    Vector3(1, 1, -1),
    Vector3(1, -1, -1),
    Vector3(-1, -1, -1),
    Vector3(-1, 1, -1),

    // Front face
    Vector3(1, 1, 1),
    Vector3(1, -1, 1),
    Vector3(-1, -1, 1),
    Vector3(-1, 1, 1),
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
    final rz = Matrix4.rotationZ(GameTime.instance.stateTime);
    final ry = Matrix4.rotationY(GameTime.instance.stateTime * 0.5);
    final rx = Matrix4.rotationY(GameTime.instance.stateTime * 0.1);
    final translation = Matrix4.translation(Vector3(0, 0, -10));
    final view = makeViewMatrix(Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0));
    final projection = makePerspectiveMatrix(pi / 2, 1, 0.1, 100);

    final mvp = projection * view * translation * rz * ry * rx;
    List<Vector3> transformed = [];
    for (final v in cube) {
      transformed.add(mvp.transformed3(v));
    }

    // debugPrint("transformed: $transformed");

    // calculate center
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = const Color(0xFFff0000)
      ..strokeWidth = 4.0;
    // ..strokeJoin = StrokeJoin.round;
    const scale = 1000;
    for (final edge in cubeEdges) {
      final v1 = transformed[edge.x.toInt()];
      final v2 = transformed[edge.y.toInt()];

      canvas.drawLine(
          Offset(v1.x * scale / v1.z + cx, v1.y * scale / v1.z + cy), Offset(v2.x * scale / v2.z + cx, v2.y * scale / v2.z + cy), paint);
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
